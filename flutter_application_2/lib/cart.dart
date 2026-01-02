class CartItem {
  final int id;
  final String title;
  final String author;
  final String description;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    this.quantity = 1,
  });
}

class Cart {
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  Cart._internal();

  final List<CartItem> _items = [];

  // READ-ONLY ACCESS
  List<CartItem> get items => List.unmodifiable(_items);

  // =========================
  // ADD ITEM
  // =========================
  void addItem(CartItem newItem) {
    final index = _items.indexWhere((i) => i.id == newItem.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(newItem);
    }
  }

  // =========================
  // REMOVE ONE ITEM
  // =========================
  void removeItem(int id) {
    _items.removeWhere((item) => item.id == id);
  }

  // =========================
  // DECREASE QUANTITY
  // =========================
  void decreaseQuantity(int id) {
    final index = _items.indexWhere((i) => i.id == id);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
    }
  }

  // =========================
  // CLEAR CART
  // =========================
  void clear() {
    _items.clear();
  }

  // =========================
  // TOTAL ITEMS COUNT
  // =========================
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
}
