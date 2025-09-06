import 'package:flutter/material.dart';
import '../database/connect_db.dart';
import '../models/note.dart';
import '../models/utilisateur.dart';
import 'edition_notes.dart';
import 'profil.dart';

class ListeNotes extends StatefulWidget {
  final Utilisateur utilisateur;

  const ListeNotes({super.key, required this.utilisateur});

  @override
  _ListeNotesState createState() => _ListeNotesState();
}

class _ListeNotesState extends State<ListeNotes> {
  List<Note> _notes = [];
  bool _chargementEnCours = true;

  @override
  void initState() {
    super.initState();
    _chargerNotes();
  }

  Future<void> _chargerNotes() async {
    final notes = await ConnectDB().obtenirNotesParUtilisateur(widget.utilisateur.id!);
    setState(() {
      _notes = notes;
      _chargementEnCours = false;
    });
  }

  void _ajouterNote() async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditionNotes(
          note: null,
          idUtilisateur: widget.utilisateur.id!,
        ),
      ),
    );

    if (resultat == true) {
      _chargerNotes();
    }
  }

  void _modifierNote(Note note) async {
    final resultat = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditionNotes(
          note: note,
          idUtilisateur: widget.utilisateur.id!,
        ),
      ),
    );

    if (resultat == true) {
      _chargerNotes();
    }
  }

  void _supprimerNote(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ConnectDB().supprimerNote(id);
                _chargerNotes();
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF002060),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profil(utilisateur: widget.utilisateur),
                ),
              );
            },
          ),
        ],
      ),
      body: _chargementEnCours
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF002060)))
          : _notes.isEmpty
          ? const Center(
        child: Text(
          'Aucune note pour le moment\nAppuyez sur le bouton + pour en créer une',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Dismissible(
              key: Key(note.id.toString()),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) => _supprimerNote(note.id!),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border(
                    left: BorderSide(color: Colors.green, width: 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    note.titre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF002060)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        note.contenu,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ajoutée le ${_formaterDate(note.dateMiseAJour)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () => _modifierNote(note),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF002060)),
                        onPressed: () => _modifierNote(note),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _supprimerNote(note.id!),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterNote,
        backgroundColor: const Color(0xFF002060),
        foregroundColor: Colors.white,
        tooltip: 'Ajouter une note',
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  String _formaterDate(DateTime date) {
    return '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}';
  }
}
