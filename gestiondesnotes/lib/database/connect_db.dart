import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/utilisateur.dart';

class ConnectDB {
  static final ConnectDB _instance = ConnectDB._interne();
  static Database? _database;

  factory ConnectDB() => _instance;

  ConnectDB._interne();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mes_notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE utilisateurs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_utilisateur TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        mot_de_passe TEXT NOT NULL,
        date_creation INTEGER NOT NULL
      )
    ''');

    // Table des notes
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        date_creation INTEGER NOT NULL,
        date_mise_a_jour INTEGER NOT NULL,
        id_utilisateur INTEGER NOT NULL,
        FOREIGN KEY(id_utilisateur) REFERENCES utilisateurs(id) ON DELETE CASCADE
      )
    ''');

    // Index pour optimiser les recherches
    await db.execute('CREATE INDEX idx_notes_id_utilisateur ON notes(id_utilisateur)');
    await db.execute('CREATE INDEX idx_notes_mise_a_jour ON notes(date_mise_a_jour)');
  }

  // Méthodes pour les utilisateurs
  Future<int> insererUtilisateur(Utilisateur utilisateur) async {
    final db = await database;
    return await db.insert('utilisateurs', utilisateur.versMap());
  }

  Future<Utilisateur?> obtenirUtilisateurParNom(String nomUtilisateur) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'utilisateurs',
      where: 'nom_utilisateur = ?',
      whereArgs: [nomUtilisateur],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Utilisateur.depuisMap(maps.first);
    }
    return null;
  }

  Future<bool> validerUtilisateur(String nomUtilisateur, String motDePasse) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'utilisateurs',
        where: 'nom_utilisateur = ? AND mot_de_passe = ?',
        whereArgs: [nomUtilisateur, motDePasse],
        limit: 1,
      );

      print('Validation utilisateur: $nomUtilisateur');
      print('Résultats de la requête: ${maps.length}');

      return maps.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la validation: $e');
      return false;
    }
  }

  // Méthodes pour les notes
  Future<int> insererNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.versMap());
  }

  Future<List<Note>> obtenirNotesParUtilisateur(int idUtilisateur) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id_utilisateur = ?',
      whereArgs: [idUtilisateur],
      orderBy: 'date_mise_a_jour DESC',
    );
    return List.generate(maps.length, (i) => Note.depuisMap(maps[i]));
  }

  Future<int> mettreAJourNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.versMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> supprimerNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Utilisateur>> obtenirTousLesUtilisateurs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('utilisateurs');
    return List.generate(maps.length, (i) => Utilisateur.depuisMap(maps[i]));
  }

  Future<void> fermer() async {
    final db = await database;
    db.close();
  }

  Future<String?> obtenirMotDePasseParEmail(String email) async {
    final db = await database; // votre connexion à la DB
    final result = await db.query(
      'utilisateurs',
      columns: ['mot_de_passe'],
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first['mot_de_passe'] as String;
    }
    return null;
  }

}