import 'package:flutter/material.dart';
import 'package:flutter_notes/urls.dart';
import 'package:http/http.dart';

class CreateNotesScreen extends StatefulWidget {
  final Client client;
  const CreateNotesScreen({super.key, required this.client});

  @override
  State<CreateNotesScreen> createState() => _CreateNotesScreenState();
}

class _CreateNotesScreenState extends State<CreateNotesScreen> {
  TextEditingController addNoteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create"),
        ),
        body: Column(
          children: [
            TextField(
              controller: addNoteController,
              maxLines: 8,
            ),
            ElevatedButton(              
              onPressed: () {
                widget.client.post(createUrl, body: {'body': addNoteController.text});
                Navigator.pop(context);
              },
              child: Text(
                'Create Note',
              ),
            ),
          ],
        ));
  }
}
