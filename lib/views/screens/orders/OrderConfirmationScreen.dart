import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String userId;

  const OrderConfirmationScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  Future<List<Map<String, dynamic>>> _fetchOrderDetails() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching order details: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15203D),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF15203D),
        title: const Text(
          'My Order',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Failed to load order details.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final orderList = snapshot.data!;

          return ListView.builder(
            itemCount: orderList.length,
            itemBuilder: (context, index) {
              final orderData = orderList[index];

              final Timestamp? orderTime = orderData['timestamp'] as Timestamp?;
              final DateTime? dateTime =
              orderTime != null ? orderTime.toDate() : null;
              final String formattedDate = dateTime != null
                  ? "${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}"
                  : 'Unknown Date';

              final int status = orderData['status'] ?? 0;
              final String statusText = status == 0 ? 'Pending' : 'confirm';

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  color: const Color(0xFF152949),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        if (orderData['imageUrl'] != null &&
                            orderData['imageUrl'].isNotEmpty)
                          Image.network(
                            orderData['imageUrl'],
                            width: 100,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  orderData['productName']?.toString() ??
                                      'Unknown Product',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Rs: ${orderData['price']?.toString() ?? 'N/A'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Payment ID: ${orderData['paymentId']?.toString() ?? 'N/A'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Date: $formattedDate',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 30, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF23325B),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        elevation: 1,
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        statusText,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero,
                                        ),
                                        elevation: 1,
                                      ),
                                      onPressed: () {
                                        // Implement cancellation logic here
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
    );
  }
}
