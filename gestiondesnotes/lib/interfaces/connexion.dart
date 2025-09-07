import 'package:flutter/material.dart';
import '../database/connect_db.dart';
import 'liste_notes.dart';
import 'inscription.dart';
import 'mot_de_passe.dart';

class Connexion extends StatefulWidget {
  final String? nomUtilisateurPrefill;

  const Connexion({super.key, this.nomUtilisateurPrefill});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();
  final _controleurNomUtilisateur = TextEditingController();
  final _controleurMotDePasse = TextEditingController();
  bool _chargementEnCours = false;
  String? _messageErreur;

  @override
  void initState() {
    super.initState();
    if (widget.nomUtilisateurPrefill != null) {
      _controleurNomUtilisateur.text = widget.nomUtilisateurPrefill!;
    }
  }

  void _seConnecter() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _chargementEnCours = true;
        _messageErreur = null;
      });

      final estValide = await ConnectDB().validerUtilisateur(
        _controleurNomUtilisateur.text.trim(),
        _controleurMotDePasse.text.trim(),
      );

      if (mounted) {
        setState(() {
          _chargementEnCours = false;
        });

        if (estValide) {
          final utilisateur = await ConnectDB().obtenirUtilisateurParNom(
            _controleurNomUtilisateur.text.trim(),
          );

          if (utilisateur != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ListeNotes(utilisateur: utilisateur),
              ),
            );
          } else {
            setState(() {
              _messageErreur = 'Une erreur s\'est produite lors de la connexion';
            });
          }
        } else {
          setState(() {
            _messageErreur = 'Nom d\'utilisateur ou mot de passe incorrect';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Connexion',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF002060),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.note_alt_rounded,
                  size: 100,
                  color: Color(0xFF002060),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gestion des Notes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF002060),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _controleurNomUtilisateur,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom d\'utilisateur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Champ Mot de passe
                TextFormField(
                  controller: _controleurMotDePasse,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MotDePasseOublie()),
                      );
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Color(0xFF002060)),
                    ),
                  ),
                ),
                if (_messageErreur != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _messageErreur!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                _chargementEnCours
                    ? const CircularProgressIndicator(color: Color(0xFF002060))
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _seConnecter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Inscription()),
                    );
                  },
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(
                      color: Color(0xFF002060),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controleurNomUtilisateur.dispose();
    _controleurMotDePasse.dispose();
    super.dispose();
  }
}
