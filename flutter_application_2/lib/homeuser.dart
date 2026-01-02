import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_screen.dart';

import 'login.dart';
import 'details_users.dart';
import 'cart.dart';

class Homeuser extends StatefulWidget {
  const Homeuser({super.key});

  @override
  State<Homeuser> createState() => _HomeuserState();
}

class _HomeuserState extends State<Homeuser> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];

  /* =========================
     INIT
  ========================= */
  @override
  void initState() {
    super.initState();
    fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  /* =========================
     FETCH BOOKS
  ========================= */
  Future<void> fetchBooks() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      "https://phase2mobile.onrender.com/api.php?action=get_books",
    );

    try {
      final response = await http.get(url);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          _books = data.cast<Map<String, dynamic>>();
          _filteredBooks = List.from(_books);
        });
      } else {
        debugPrint("Server error");
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }

    setState(() => _isLoading = false);
  }

  /* =========================
     SEARCH
  ========================= */
  void _filterBooks() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredBooks = List.from(_books);
      } else {
        _filteredBooks = _books.where((book) {
          return (book['title'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query) ||
              (book['author'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query) ||
              (book['description'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /* =========================
     UI
  ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("Books Feed"),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),

      );
    },
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CartScreen(),
          ),
        );
      },
    ),
  ],
),


      /* SEARCH BAR */
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search books...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBooks.isEmpty
              ? const Center(child: Text("No books found"))
              : RefreshIndicator(
                  onRefresh: fetchBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /* IMAGE */
                            if (book['image'] != null &&
                                book['image'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                child: Image.network(
                                  book['image'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title'] ?? 'No title',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Author: ${book['author'] ?? 'N/A'}",
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book['description'] ??
                                        'No description',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        child:
                                            const Text("View Details"),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ItemDetails(
                                                title: book['title'],
                                                details:
                                                    book['description'],
                                                image:
                                                    book['image'] ?? '',
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      ElevatedButton.icon(
                                        icon: const Icon(
                                            Icons.shopping_cart),
                                        label:
                                            const Text("Add to Cart"),
                                        onPressed: () {
                                          Cart().addItem(
                                            CartItem(
                                              id: int.parse(
                                                  book['id'].toString()),
                                              title: book['title'],
                                              author: book['author'],
                                              description:
                                                  book['description'],
                                              image:
                                                  book['image'] ?? '',
                                            ),
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text("Added to cart"),
                                              duration:
                                                  Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
