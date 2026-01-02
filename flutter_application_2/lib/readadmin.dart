import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'homeadmin.dart';
import 'insert_admin.dart'; // Page1

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  bool isLoading = true;
  List<Map<String, dynamic>> bookList = [];

  @override
  void initState() {
    super.initState();
    readData();
  }

  // =========================
  // FETCH BOOKS
  // =========================
  Future<void> readData() async {
    setState(() => isLoading = true);

    final url =
        "https://phase2mobile.onrender.com/api.php?action=get_books";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as List<dynamic>;

        setState(() {
          bookList =
              extractedData.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  // =========================
  // DELETE BOOK
  // =========================
  Future<void> deleteBookItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleteUrl =
          "https://phase2mobile.onrender.com/api.php?action=delete_book&id=$id";
      await http.get(Uri.parse(deleteUrl));
      readData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => const Homeadmin()),
              (route) => false,
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 96, 3, 119),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookList.isEmpty
              ? const Center(
                  child: Text('No books available.'),
                )
              : RefreshIndicator(
                  onRefresh: readData,
                  child: ListView.builder(
                    itemCount: bookList.length,
                    itemBuilder: (context, index) {
                      final book = bookList[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: book['image'] != null &&
                                  book['image']
                                      .toString()
                                      .isNotEmpty
                              ? Image.network(
                                  book['image'],
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book),
                          title: Text(
                            book['title'] ?? 'No title',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Author: ${book['author']}"),
                              Text(
                                "Price: \$${book['price']}",
                                style: const TextStyle(
                                    color: Colors.green),
                              ),
                              Text(
                                book['description'] ?? '',
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Page1(
                                        book: book,
                                      ),
                                    ),
                                  );
                                  readData();
                                },
                              ),

                              // DELETE
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    deleteBookItem(
                                        book['id'].toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
