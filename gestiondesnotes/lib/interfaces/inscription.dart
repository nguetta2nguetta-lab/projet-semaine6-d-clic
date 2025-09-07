import 'package:flutter/material.dart';
import '../database/connect_db.dart';
import '../models/utilisateur.dart';
import 'connexion.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  final _controleurNomUtilisateur = TextEditingController();
  final _controleurEmail = TextEditingController();
  final _controleurMotDePasse = TextEditingController();
  final _controleurConfirmationMotDePasse = TextEditingController();
  bool _chargementEnCours = false;
  String? _messageErreur;

  void _sInscrire() async {
    if (_formKey.currentState!.validate()) {
      if (_controleurMotDePasse.text != _controleurConfirmationMotDePasse.text) {
        setState(() {
          _messageErreur = 'Les mots de passe ne correspondent pas';
        });
        return;
      }

      setState(() {
        _chargementEnCours = true;
        _messageErreur = null;
      });

      final utilisateurExistant = await ConnectDB().obtenirUtilisateurParNom(_controleurNomUtilisateur.text.trim());
      if (utilisateurExistant != null) {
        setState(() {
          _chargementEnCours = false;
          _messageErreur = 'Ce nom d\'utilisateur est déjà pris';
        });
        return;
      }

      final nouvelUtilisateur = Utilisateur(
        nomUtilisateur: _controleurNomUtilisateur.text.trim(),
        email: _controleurEmail.text.trim(),
        motDePasse: _controleurMotDePasse.text,
      );

      try {
        await ConnectDB().insererUtilisateur(nouvelUtilisateur);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Connexion(nomUtilisateurPrefill: _controleurNomUtilisateur.text.trim()),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès! Vous pouvez maintenant vous connecter.'),
              backgroundColor: Color(0xFF002060),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _chargementEnCours = false;
          _messageErreur = 'Une erreur s\'est produite lors de la création du compte';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF002060),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.app_registration,
                  size: 100,
                  color: Color(0xFF002060),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inscription',
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
                      return 'Veuillez entrer un nom d\'utilisateur';
                    }
                    if (value.length < 3) {
                      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controleurEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controleurConfirmationMotDePasse,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    return null;
                  },
                ),
                if (_messageErreur != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _messageErreur!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                _chargementEnCours
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF002060)))
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sInscrire,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Créer le compte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous avez déjà un compte ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Connexion()),
                        );
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Color(0xFF002060),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
    _controleurEmail.dispose();
    _controleurMotDePasse.dispose();
    _controleurConfirmationMotDePasse.dispose();
    super.dispose();
  }
}
