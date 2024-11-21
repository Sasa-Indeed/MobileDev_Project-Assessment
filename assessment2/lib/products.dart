import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _selectedIndex = 1; // Set index for "Products"
  List<dynamic> items = [];
  List<dynamic> cart = []; // List to store cart items

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/carts'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> allProducts = [];
      for (var cart in data['carts']) {
        allProducts.addAll(cart['products']);
      }
      setState(() {
        items = allProducts;
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

  void addToCart(dynamic item) {
    setState(() {
      cart.add(item); // Add item to cart
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/Cart', arguments: cart); // Pass cart items to Cart screen
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            'Product List',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        ),
        backgroundColor: Colors.blue[200],
      ),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_cart),
                trailing: const Icon(Icons.add),
                title: Text(
                    item['title'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                    )
                ),
                subtitle: Text(
                    'Price: \$${item['price']}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.green,
                    ),
                ),
                onTap: () => addToCart(item),
              ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home,size: 35,),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu, size: 35,),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, size: 35,),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: Text(
                        '${cart.length}', // Display cart item count
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[100],
        onTap: _onItemTapped,
      ),
    );
  }
}
