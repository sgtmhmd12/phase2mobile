import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'homeadmin.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _form = GlobalKey<FormState>();

  String title = "";
  String description = "";
  String author = "";
  String imageUrl = "";

  /* =========================
     ADD BOOK (POST)
  ========================= */
  Future<void> addBook() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    final url = Uri.parse(
      "https://phase2mobile.onrender.com/api.php?action=add_book",
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: json.encode({
              "title": title,
              "author": author,
              "description": description,
              "image": imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Book added successfully")),
        );
        _form.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server error: ${response.statusCode}\n${response.body}",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }
  }

  /* =========================
     UI
  ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Homeadmin()),
            );
          },
        ),
      ),
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => title = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(labelText: "Author"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => author = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration:
                    const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => description = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Image URL (https://...)",
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => imageUrl = v!,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: addBook,
                child: const Text("Add Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
