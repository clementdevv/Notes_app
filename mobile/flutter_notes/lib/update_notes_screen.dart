import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notes/auth_service.dart';
import 'package:flutter_notes/urls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class UpdateNotesScreen extends StatefulWidget {
  final Client client;
  final int id;
  final String note;
  const UpdateNotesScreen(
      {super.key, required this.client, required this.id, required this.note});

  @override
  State<UpdateNotesScreen> createState() => _UpdateNotesScreenState();
}

class _UpdateNotesScreenState extends State<UpdateNotesScreen> {
  TextEditingController updateNoteController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    updateNoteController.text = widget.note;
    super.initState();
  }

  @override
  void dispose() {
    updateNoteController.dispose();
    super.dispose();
  }
 
  Future<void> updateNote() async {
    if (updateNoteController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Authentication error - please log in again')),
        );
        return;
      }

      final response = await http.put(
        updateUrl(widget.id),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'body': updateNoteController.text}),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update note (${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Note"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 15,
          ),
          child: Column(
            children: [
              TextField(
                controller: updateNoteController,
                maxLines: 8,
                 decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateNote,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Update',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ));
  }
}
