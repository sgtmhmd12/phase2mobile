import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'homeadmin.dart';

class Page1 extends StatefulWidget {
  final Map<String, dynamic>? book;

  const Page1({super.key, this.book});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String title = '';
  String author = '';
  String description = '';
  String price = '';
  String existingImage = '';

  File? _imageFile;        // Mobile
  Uint8List? _webImage;   // Web

  bool get isEdit => widget.book != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      title = widget.book!['title'] ?? '';
      author = widget.book!['author'] ?? '';
      description = widget.book!['description'] ?? '';
      price = widget.book!['price'].toString();
      existingImage = widget.book!['image'] ?? '';
    }
  }

  /* =========================
     PICK IMAGE (WEB + MOBILE)
  ========================= */
  Future<void> pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImage = null;
        });
      }
    }
  }

  /* =========================
     SUBMIT (ADD / UPDATE)
  ========================= */
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!isEdit && _imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    final uri = Uri.parse(
      isEdit
          ? "https://phase2mobile.onrender.com/api.php?action=update_book"
          : "https://phase2mobile.onrender.com/api.php?action=add_book",
    );

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
      } else if (_webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _webImage!,
            filename: 'upload.jpg',
          ),
        );
      }

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? "Book updated successfully"
                  : "Book added successfully",
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homeadmin()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error")),
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
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => title = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: "Author"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => author = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => description = v!,
              ),
              const SizedBox(height: 15),

              TextFormField(
                initialValue: price,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                onSaved: (v) => price = v!,
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: Text(
                  isEdit ? "Change Image (Optional)" : "Select Image",
                ),
              ),

              const SizedBox(height: 10),

              if (_webImage != null)
                Image.memory(_webImage!, height: 150)
              else if (_imageFile != null)
                Image.file(_imageFile!, height: 150)
              else if (isEdit && existingImage.isNotEmpty)
                Image.network(existingImage, height: 150),

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
