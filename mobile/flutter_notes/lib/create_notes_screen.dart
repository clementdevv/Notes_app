import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notes/auth_service.dart';
import 'package:flutter_notes/urls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class CreateNotesScreen extends StatefulWidget {
  final Client client;
  const CreateNotesScreen({super.key, required this.client});

  @override
  State<CreateNotesScreen> createState() => _CreateNotesScreenState();
}

class _CreateNotesScreenState extends State<CreateNotesScreen> {
  TextEditingController addNoteController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    addNoteController.dispose();
    super.dispose();
  }

  Future<void> createNote() async {
    if (addNoteController.text.isEmpty) return;

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

      final response = await http.post(
        createUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'body': addNoteController.text}),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create note (${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Error creating note: $e');
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
          title: const Text("Create New Note"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 15,
          ),
          child: Column(
            children: [
              TextField(
                controller: addNoteController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                onPressed: isLoading ? null : createNote,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Create',
                      ),
              ),
            ],
          ),
        ));
  }
}
