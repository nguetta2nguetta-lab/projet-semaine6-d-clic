import 'package:flutter/material.dart';
import '../database/connect_db.dart';
import '../models/note.dart';

class EditionNotes extends StatefulWidget {
  final Note? note;
  final int idUtilisateur;

  const EditionNotes({super.key, this.note, required this.idUtilisateur});

  @override
  _EditionNotesState createState() => _EditionNotesState();
}

class _EditionNotesState extends State<EditionNotes> {
  final _formKey = GlobalKey<FormState>();
  final _controleurTitre = TextEditingController();
  final _controleurContenu = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _controleurTitre.text = widget.note!.titre;
      _controleurContenu.text = widget.note!.contenu;
    }
  }

  Future<void> _sauvegarderNote() async {
    if (_formKey.currentState!.validate()) {
      if (widget.note == null) {
        final nouvelleNote = Note(
          titre: _controleurTitre.text,
          contenu: _controleurContenu.text,
          idUtilisateur: widget.idUtilisateur,
        );
        await ConnectDB().insererNote(nouvelleNote);
      } else {
        final noteMiseAJour = Note(
          id: widget.note!.id,
          titre: _controleurTitre.text,
          contenu: _controleurContenu.text,
          idUtilisateur: widget.note!.idUtilisateur,
          dateCreation: widget.note!.dateCreation,
          dateMiseAJour: DateTime.now(),
        );
        await ConnectDB().mettreAJourNote(noteMiseAJour);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Nouvelle Note' : 'Modifier la Note',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF002060),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _sauvegarderNote,
          ),
        ],
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Champ Titre
                        Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(12),
                          child: TextFormField(
                            controller: _controleurTitre,
                            decoration: InputDecoration(
                              hintText: 'Titre',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un titre';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Champ Contenu
                        Expanded(
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(12),
                            child: TextFormField(
                              controller: _controleurContenu,
                              decoration: InputDecoration(
                                hintText: 'Contenu',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none),
                                fillColor: Colors.white,
                                filled: true,
                                alignLabelWithHint: true,
                              ),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un contenu';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Boutons Annuler / Enregistrer
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF002060)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(
                                      color: Color(0xFF002060),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _sauvegarderNote,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF002060),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controleurTitre.dispose();
    _controleurContenu.dispose();
    super.dispose();
  }
}
