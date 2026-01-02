import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'homeadmin.dart';

class Page1 extends StatefulWidget {
  final Map<String, dynamic>? book; // 👈 for edit

  const Page1({super.key, this.book});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _form = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String title = "";
  String author = "";
  String description = "";
  String price = "";
  String existingImage = "";

  File? _imageFile;

  bool get isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      title = widget.book!['title'];
      author = widget.book!['author'];
      description = widget.book!['description'];
      price = widget.book!['price'].toString();
      existingImage = widget.book!['image'] ?? '';
    }
  }

  /* =========================
     PICK IMAGE
  ========================= */
  Future<void> pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  /* =========================
     SUBMIT (ADD / UPDATE)
  ========================= */
  Future<void> submit() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    final uri = Uri.parse(
      isEdit
          ? "https://phase2mobile.onrender.com/api.php?action=update_book"
          : "https://phase2mobile.onrender.com/api.php?action=add_book",
    );

    if (!isEdit && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    try {
      final request = http.MultipartRequest("POST", uri);

      request.fields['title'] = title;
      request.fields['author'] = author;
      request.fields['description'] = description;
      request.fields['price'] = price;

      if (isEdit) {
        request.fields['id'] = widget.book!['id'].toString();
        request.fields['existing_image'] = existingImage;
      }

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
          ),
        );
      }

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? "Book updated successfully" : "Book added successfully",
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homeadmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error")),
        );
      }
    } catch (e) {
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
        title: Text(isEdit ? "Edit Book" : "Add Book"),
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
                initialValue: title,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => title = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: "Author"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => author = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: description,
                decoration:
                    const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => description = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: price,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => price = v!,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: Text(isEdit
                    ? "Change Image (Optional)"
                    : "Select Image"),
              ),

              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(_imageFile!, height: 150),
                )
              else if (isEdit && existingImage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.network(existingImage, height: 150),
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: submit,
                child: Text(isEdit ? "Update Book" : "Add Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
