import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'views/screens/orders/OrderScreen.dart';
import 'views/screens/profiles/MyProfileScreen.dart';
import 'views/screens/cards/AddToCardScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String orderId = FirebaseFirestore.instance.collection('orders').doc().id;
  String username = "Welcome";
  String email = "Loading...";
  int _selectedIndex = 0;
  String searchQuery = "";
  late String _selectedCategory ='All';

  final List<String> _categories = [
    "All",
    "Digital Watch",
    "Campus",
    "Smart Watch",
    "Luxury Watch",
    "Sports Watch",
    "Adidas",
    "Vintage Watch",
    "Casual Watch",
    "Ajanta",
    "Hybrid Watch",
  ];




  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        email = currentUser.email ?? 'No Email';


        if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
          username = currentUser.displayName!;
        } else {

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          if (userDoc.exists) {
            username = userDoc['username'] ?? 'User';
          } else {
            username = 'User';
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      username = 'Error';
    }

    setState(() {}); // Refresh UI
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SafeArea(

      child: Scaffold(
        backgroundColor: Color(0xFF15203D),
        appBar: _selectedIndex == 1 || _selectedIndex == 2
            ? null
            : AppBar(

          centerTitle: true,
          backgroundColor: Color(0xFF0E172C),
          title: Text(
            'Welcome, $username!',
            style: const TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 2.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                ),
              ),

            if (_selectedIndex == 0)
            SizedBox(

              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: _selectedCategory == category ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: _selectedCategory == category,
                      selectedColor: Colors.green,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = category; // Update the selected category
                        });
                      },
                    ),
                  );
                },
              ),
            ),


            Expanded(child: _buildPageContent(screenSize)),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Color(0xFF0E172C),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(Size screenSize) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(screenSize);
      case 1:
        return const AddCartScreen();
      case 2:
        return  ProfileScreen();
      default:
        return _buildHomeContent(screenSize);
    }
  }

  Widget _buildHomeContent(Size screenSize) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance.collection('products').snapshots(),


      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        final products = snapshot.data!.docs.where((doc) {
          var productData = doc.data() as Map<String, dynamic>;
          String productName = productData['name'] ?? '';
          return productName.toLowerCase().contains(searchQuery);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: screenSize.width / (screenSize.height / 1.5),

          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var productData = products[index].data() as Map<String, dynamic>;
            String imageUrl = productData['imageUrl'] ?? '';
            String productName = productData['name'] ?? 'Unnamed';
            double price = productData['price']?.toDouble() ?? 0.0;
            String desc = productData['desc'] ?? 'No description';
            String productId = products[index].id;
            String sellerId = productData['seller_Id'];
            // String userId = productData['userId'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderScreen(
                      imageUrl: imageUrl,
                      productName: productName,
                      price: price,
                      desc: desc,
                      productId: productId,
                      orderId: orderId,
                      sellerId: sellerId,
                    ),
                  ),
                );
              },
              child: Card(
                shadowColor: Colors.blue,
                color: Color(0xFF152949),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(1),
                        ),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                        ),
                      )
                          : const Icon(Icons.image, size: 60),
                    ),
                    Text(
                      productName,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        fontWeight: FontWeight.bold,color: Colors.white
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rs: ₹$price',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.040,
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 4,),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Center(child: Text('20 % off',style: TextStyle(color: Colors.white,fontSize: 16),)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
