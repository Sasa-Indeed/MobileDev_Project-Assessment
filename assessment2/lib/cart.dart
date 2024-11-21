import 'package:flutter/material.dart';

class ShoppingCartScreen extends StatefulWidget {
  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int _selectedIndex = 2; // Set index for "Cart"
  List<dynamic> cart = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
    if (args != null) {
      setState(() {
        cart = args;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/Product');
          break;
        default:
          break;
      }
    });
  }

  double calculateTotalPrice() {
    return cart.fold(0, (sum, item) => sum + item['price']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            'Shopping Cart',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[200],
      ),
      body: cart.isEmpty
          ? Center(
          child: Image.asset("asset/EmptyCart.jpg"),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text('Price: \$${item['price']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final total = calculateTotalPrice();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Checkout'),
                    content: Text('Total Price: \$${total.toStringAsFixed(2)}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          setState(() {
                            cart.clear(); // Clear the cart
                          });
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[200],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, size: 35,),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, size: 35,),
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
