import 'package:flutter/material.dart';
import 'package:flutter_notes/urls.dart';
import 'package:http/http.dart';

class UpdateNotesScreen extends StatefulWidget {
  final Client client;
  final int id;
  final String note;
  const UpdateNotesScreen({super.key, required this.client, required this.id, required this.note});

  @override
  State<UpdateNotesScreen> createState() => _UpdateNotesScreenState();
}

class _UpdateNotesScreenState extends State<UpdateNotesScreen> {
  TextEditingController updateNoteController = TextEditingController();

  @override
  void initState() {
    updateNoteController.text = widget.note;    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Update"),
        ),
        body: Column(
          children: [
            TextField(
              controller: updateNoteController,
              maxLines: 8,
            ),
            ElevatedButton(              
              onPressed: () {
                widget.client.put(updateUrl(widget.id), body: {'body': updateNoteController.text});
                Navigator.pop(context);
              },
              child: Text(
                'Update Note',
              ),
            ),
          ],
        ));
  }
}