import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'details_users.dart';

// READ DATA (BOOKS)
class Homeuser extends StatefulWidget {
  const Homeuser({super.key});

  @override
  State<Homeuser> createState() => _HomeuserState();
}

class _HomeuserState extends State<Homeuser> {
  final TextEditingController _searchController =
      TextEditingController(); // linked with my text fields

  String _searchText = ""; // for search
  bool _isLoading = true; // if data is loading

  List<Map<String, dynamic>> _allBooks = []; // all books from backend
  List<Map<String, dynamic>> _filteredBooks = []; // filtered books

  @override
  void initState() {
    super.initState();
    readData();
    _searchController.addListener(_onSearchTextChanged);
  }

  // called when search text changes
  void _onSearchTextChanged() {
    setState(() {
      _searchText = _searchController.text;
      _filterBooks();
    });
  }

  // filter books based on title, author, or description
  void _filterBooks() {
    if (_searchText.isEmpty) {
      _filteredBooks = List.from(_allBooks);
    } else {
      _filteredBooks = _allBooks.where((book) {
        final title =
            (book['title'] ?? '').toString().toLowerCase();
        final author =
            (book['author'] ?? '').toString().toLowerCase();
        final description =
            (book['description'] ?? '').toString().toLowerCase();

        final searchTextLower = _searchText.toLowerCase();

        return title.contains(searchTextLower) ||
            author.contains(searchTextLower) ||
            description.contains(searchTextLower);
      }).toList();
    }
  }

  // FETCH BOOKS FROM PHP BACKEND
  Future<void> readData() async {
    setState(() {
      _isLoading = true;
    });

    // 🔗 PHP API URL (replace with your real one)
    var url =
  "https://YOUR-RAILWAY-DOMAIN.up.railway.app/Books.php?action=get_books";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as List<dynamic>;

        _allBooks.clear();

        for (var book in extractedData) {
          if (book is Map<String, dynamic>) {
            _allBooks.add(book);
          }
        }

        _filterBooks();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books Feed'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const login()),
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search by title, author, or description...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(179, 132, 46, 185),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    const Color.fromARGB(60, 168, 127, 218),
                hintStyle:
                    const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBooks.isEmpty
              ? const Center(
                  child: Text('No books found. Pull to refresh?'),
                )
              : RefreshIndicator(
                  onRefresh: readData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final book = _filteredBooks[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetails(
                                  title:
                                      book['title'] ?? 'No Title',
                                  details: book['description'] ??
                                      'No Description',
                                  image: book['image'] ?? '', // ✅ FIX
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // BOOK IMAGE (thumbnail)
                                if (book['image'] != null &&
                                    book['image']
                                        .toString()
                                        .isNotEmpty)
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      book['image'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context,
                                          error, stackTrace) {
                                        return const SizedBox();
                                      },
                                    ),
                                  ),

                                Padding(
                                  padding:
                                      const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['title'] ??
                                            'No Title',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                          color:
                                              Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Author: ${book['author'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Colors.grey[700],
                                          fontStyle:
                                              FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        book['description'] ??
                                            'No Description',
                                        maxLines: 3,
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
