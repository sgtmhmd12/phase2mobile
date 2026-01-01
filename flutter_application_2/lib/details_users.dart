import 'package:flutter/material.dart';

// DETAILS PAGE (BOOK DETAILS)
class ItemDetails extends StatelessWidget {
  final String title;
  final String details;
  final String image; // ✅ NEW: image URL

  const ItemDetails({
    super.key,
    required this.title,
    required this.details,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 96, 3, 119),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BOOK IMAGE
            if (image.isNotEmpty)
              Image.network(
                image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                details,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
