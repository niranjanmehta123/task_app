import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OrderScreen extends StatefulWidget {

  final String sellerId;
  final String productId;
  final String imageUrl;
  final String productName;
  final double? price;
  final String desc;
  final String orderId;

  const OrderScreen({
    Key? key,
    required this.productId,
    required this.imageUrl,
    required this.productName,
    required this.price,
    required this.desc,
    required this.orderId,
    required this.sellerId,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF15203D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15203D),
          title: Text(widget.productName, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: double.infinity,
                height: screenSize.height * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  image: widget.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: const Color(0xFF192544),
                ),
                child: widget.imageUrl.isEmpty
                    ? const Center(child: Icon(Icons.image, size: 100))
                    : null,
              ),
              SizedBox(height: screenSize.height * 0.03),
              // Product Name
              Text(
                widget.productName,
                style: TextStyle(
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              // Product Price
              Text(
                'Price: ₹${widget.price}',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '20 % off',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              // Product Description
              Text(
                'Description: ${widget.desc}',
                style: TextStyle(
                  fontSize: screenSize.width * 0.05,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: screenSize.height * 0.10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: () {
                      _addToCart(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.12,
                        vertical: screenSize.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  // Buy Now Button
                  ElevatedButton(
                    onPressed: () {
                      _showPaymentOptions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C3965),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.12,
                        vertical: screenSize.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 1,
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions() {
    var screenSize = MediaQuery.of(context).size;
    showModalBottomSheet(

      context: context,
      builder: (context) => Container(
        color: Color(0xFFE6E7EC),
        width: double.infinity,
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _cashOnDelivery,
              style: ElevatedButton.styleFrom(
               backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.30,
                  vertical: screenSize.height * 0.015,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 1,
              ),
              child: const Text('Cash on Delivery',style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C3965),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.30,
                  vertical: screenSize.height * 0.015,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 1,
              ),
              child: const Text('Online Payment',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cashOnDelivery() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Fluttertoast.showToast(msg: "User not logged in.");
        return;
      }

      String orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'productId': widget.productId,
        'productName': widget.productName,
        'price': widget.price,
        'imageUrl': widget.imageUrl,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 0,
        'seller_Id': widget.sellerId,
        'paymentMethod': 'COD',
      });

      Navigator.pop(context); // Close the bottom sheet
      Fluttertoast.showToast(msg: "Order Successful (COD)");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to process COD order: $e");
    }
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_HenD7YeMcwJuEC',
      'amount': (widget.price! * 100).toInt(),
      'name': 'Niranjan Kumar',
      'description': widget.productName,
      'prefill': {
        'contact': '9155077691',
        'email': 'niranjanskedugaon@gmail.com',
      },
      'theme': {
        'color': '#3399cc',
      },
    };

    try {
      razorpay.open(options);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Fluttertoast.showToast(msg: "User not logged in.");
        return;
      }

      String orderId = FirebaseFirestore.instance.collection('orders').doc().id;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'productId': widget.productId,
        'productName': widget.productName,
        'price': widget.price,
        'imageUrl': widget.imageUrl,
        'paymentId': response.paymentId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 1,
        'seller_Id': widget.sellerId,
        'paymentMethod': 'Online',
      });

      Navigator.pop(context); // Close the bottom sheet
      Fluttertoast.showToast(msg: "Order Successful (Online Payment)");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to save order details: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed! Error Code: ${response.code}, Message: ${response.message}",
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External Wallet Selected: ${response.walletName}",
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        Fluttertoast.showToast(msg: "User not logged in.");
        return;
      }

      await FirebaseFirestore.instance.collection('cart').add({
        'userId': userId,
        'productId': widget.productId,
        'productName': widget.productName,
        'imageUrl': widget.imageUrl,
        'price': widget.price,
        'desc': widget.desc,
      });

      Fluttertoast.showToast(msg: "${widget.productName} added to cart!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to add to cart: $e");
    }
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
}
