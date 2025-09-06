class Note {
  int? id;
  String titre;
  String contenu;
  DateTime dateCreation;
  DateTime dateMiseAJour;
  int idUtilisateur;

  Note({
    this.id,
    required this.titre,
    required this.contenu,
    required this.idUtilisateur,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  })  : dateCreation = dateCreation ?? DateTime.now(),
        dateMiseAJour = dateMiseAJour ?? DateTime.now();

  Map<String, dynamic> versMap() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'date_creation': dateCreation.millisecondsSinceEpoch,
      'date_mise_a_jour': dateMiseAJour.millisecondsSinceEpoch,
      'id_utilisateur': idUtilisateur,
    };
  }

  factory Note.depuisMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      titre: map['titre'],
      contenu: map['contenu'],
      idUtilisateur: map['id_utilisateur'],
      dateCreation: DateTime.fromMillisecondsSinceEpoch(map['date_creation']),
      dateMiseAJour: DateTime.fromMillisecondsSinceEpoch(map['date_mise_a_jour']),
    );
  }
}