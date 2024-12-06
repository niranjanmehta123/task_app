import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AddCartScreen extends StatefulWidget {
  const AddCartScreen({Key? key}) : super(key: key);

  @override
  State<AddCartScreen> createState() => _AddCartScreenState();
}

class _AddCartScreenState extends State<AddCartScreen> {
  Future<void> updateCartItem({
    required String productId,
    required int quantity,
    required double price,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(productId)
          .update({
        'quantity': quantity,
        'totalPrice': price * quantity,
      });
    } catch (e) {
      print("Error updating cart item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text(
          'No user logged in',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF15203D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15203D),
          title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No items in cart',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              );
            }

            final cartItems = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(8.0),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final data = cartItems[index].data() as Map<String, dynamic>;
                final String productId = cartItems[index].id;
                int quantity = data['quantity'] ?? 1;
                double price = data['price'] ?? 0.0;

                return Card(
                  color: const Color(0xFF152949),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: data['imageUrl'] != null
                            ? Image.network(
                          data['imageUrl'],
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['productName'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Price: ₹${price * quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity Controls
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (quantity > 1) {
                                quantity--;
                                await updateCartItem(
                                  productId: productId,
                                  quantity: quantity,
                                  price: price,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () async {
                              quantity++;
                              await updateCartItem(
                                productId: productId,
                                quantity: quantity,
                                price: price,
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('cart')
                              .doc(productId)
                              .delete();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
