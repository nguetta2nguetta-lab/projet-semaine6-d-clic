class Utilisateur {
  int? id;
  String nomUtilisateur;
  String email;
  String motDePasse;
  DateTime dateCreation;

  Utilisateur({
    this.id,
    required this.nomUtilisateur,
    required this.email,
    required this.motDePasse,
    DateTime? dateCreation,
  }) : dateCreation = dateCreation ?? DateTime.now();

  Map<String, dynamic> versMap() {
    return {
      'id': id,
      'nom_utilisateur': nomUtilisateur,
      'email': email,
      'mot_de_passe': motDePasse,
      'date_creation': dateCreation.millisecondsSinceEpoch,
    };
  }

  factory Utilisateur.depuisMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nomUtilisateur: map['nom_utilisateur'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      dateCreation: DateTime.fromMillisecondsSinceEpoch(map['date_creation']),
    );
  }
}