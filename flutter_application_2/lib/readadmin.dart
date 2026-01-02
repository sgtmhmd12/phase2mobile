import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homeadmin.dart';

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
    setState(() {
      isLoading = true;
    });

    final url =
        "https://phase2mobile.onrender.com/api.php?action=get_books";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as List<dynamic>;

        final List<Map<String, dynamic>> loadedBooks = [];

        for (var book in extractedData) {
          if (book is Map<String, dynamic>) {
            loadedBooks.add(book);
          }
        }

        setState(() {
          bookList = loadedBooks;
          isLoading = false;
        });
      }
    } catch (error) {
      debugPrint("Fetch error: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  // =========================
  // DELETE BOOK
  // =========================
  Future<void> deleteBookItem(String id) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            const Text('Are you sure you want to delete this book?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        final deleteUrl =
            "https://phase2mobile.onrender.com/api.php?action=delete_book&id=$id";

        final response = await http.get(Uri.parse(deleteUrl));

        if (response.statusCode == 200) {
          readData();
        }
      } catch (error) {
        debugPrint("Delete error: $error");
      }
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
              MaterialPageRoute(builder: (_) => const Homeadmin()),
              (Route<dynamic> route) => false,
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
                  child: Text('No books available. Add some books!'),
                )
              : RefreshIndicator(
                  onRefresh: readData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: bookList.length,
                    itemBuilder: (context, index) {
                      final book = bookList[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.all(12),
                          title: Text(
                            book['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color.fromARGB(
                                  255, 96, 3, 119),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Author: ${book['author'] ?? 'N/A'}',
                                style: TextStyle(
                                    color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['description'] ??
                                    'No Description',
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                deleteBookItem(book['id'].toString()),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
