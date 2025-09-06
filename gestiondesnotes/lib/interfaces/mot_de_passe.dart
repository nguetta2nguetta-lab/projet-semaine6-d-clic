import 'package:flutter/material.dart';
import '../database/connect_db.dart';

class MotDePasseOublie extends StatefulWidget {
  const MotDePasseOublie({super.key});

  @override
  _MotDePasseOublieState createState() => _MotDePasseOublieState();
}

class _MotDePasseOublieState extends State<MotDePasseOublie> {
  final _formKey = GlobalKey<FormState>();
  final _controleurEmail = TextEditingController();
  String? _motDePasse;
  String? _messageErreur;
  bool _chargement = false;

  void _recupererMotDePasse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _chargement = true;
        _messageErreur = null;
        _motDePasse = null;
      });

      final motDePasse = await ConnectDB().obtenirMotDePasseParEmail(
        _controleurEmail.text.trim(),
      );

      setState(() {
        _chargement = false;
        if (motDePasse != null) {
          _motDePasse = motDePasse;
        } else {
          _messageErreur = 'Aucun compte trouvé pour cet email';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF002060),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Color(0xFF002060),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controleurEmail,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre votre Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _chargement
                    ? const CircularProgressIndicator(color: Color(0xFF002060))
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _recupererMotDePasse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Afficher le mot de passe',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_motDePasse != null) ...[
                  Text(
                    'Mot de passe : $_motDePasse',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
                if (_messageErreur != null) ...[
                  Text(
                    _messageErreur!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controleurEmail.dispose();
    super.dispose();
  }
}
