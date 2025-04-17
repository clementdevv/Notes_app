import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_notes/auth_service.dart';
import 'package:flutter_notes/create_notes_screen.dart';
import 'package:flutter_notes/login_screen.dart';
import 'package:flutter_notes/note.dart';
import 'package:flutter_notes/update_notes_screen.dart';
import 'package:flutter_notes/urls.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const MyHomePage(title: 'Notes App');
    } else {
      return const LoginScreen();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _authService = AuthService();
  Client client = http.Client();
  List<Note> notes = [];
  @override
  void initState() {
    _setupAuthenticatedClient();
    _retrieveNotes();
    super.initState();
  }

  Future<void> _setupAuthenticatedClient() async {
    final token = await _authService.getAccessToken();
    if (token != null) {
      client = http.Client();
    }
  }

  _retrieveNotes() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        _logout();
        return;
      }

      notes = [];
      final response = await http.get(
        retrieveUrl,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        // Token expired or invalid
        _logout();
        return;
      }

      if (response.statusCode == 200) {
      List responseData = json.decode(response.body);
      for (var element in responseData) {
        notes.add(Note.fromMap(element));
      }
      setState(() {});
    } else {
      debugPrint('Failed to load notes. Status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }
    } catch (e) {
      debugPrint('Error retrieving notes: $e');
    }
  }

  Future<void> _deleteNote(int id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        _logout();
        return;
      }

      final response = await http.delete(
        deleteUrl(id),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        // Token expired or invalid
        _logout();
        return;
      }

      _retrieveNotes();
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  void _logout() async {
    await _authService.logout();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Row(
            children: [
              const Text("Log Out"),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _retrieveNotes();
        },
        child: notes.isEmpty
            ? const Center(
                child: Text('No notes yet. Add one with the + button on the bottom right of the screen!'),
              )
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(notes[index].note),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UpdateNotesScreen(
                            client: client,
                            id: notes[index].id,
                            note: notes[index].note,
                          ),
                        ),
                      );
                      _retrieveNotes(); // Refresh after update
                    },
                    trailing: IconButton(
                      onPressed: () => _deleteNote(notes[index].id),
                      icon: const Icon(
                        Icons.delete,
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateNotesScreen(client: client),
            ),
          );
          _retrieveNotes(); // Refresh notes after returning
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
