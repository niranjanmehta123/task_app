// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class VisibilityScreen extends StatefulWidget {
//   @override
//   State<VisibilityScreen> createState() => _VisibilityScreenState();
// }
//
// class _VisibilityScreenState extends State<VisibilityScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firestore Visibility Example'),
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('visiable')
//             .doc('tjTDkxi62PFN1sIYU0lT')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(
//               child: Text('No data found in Firestore'),
//             );
//           }
//
//           final int visibility = snapshot.data!.get('visiable');
//
//           return Center(
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: visibility == 1 ? Colors.blue : Colors.grey,
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               ),
//               onPressed: () {
//
//               },
//               child: Text(
//                 visibility == 1 ? 'Visible' : 'Not Visible',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import 'OrderConfirmationScreen.dart';
//
// class CardScreen extends StatefulWidget {
//   final String productId;
//   final String imageUrl;
//   final String productName;
//   final double? price;
//   final String desc;
//   final String orderId;
//
//   const CardScreen({
//     Key? key,
//     required this.productId,
//     required this.imageUrl,
//     required this.productName,
//     required this.price,
//     required this.desc,
//     required this.orderId ,
//   }) : super(key: key);
//
//   @override
//   State<CardScreen> createState() => _CardScreenState();
// }
//
// class _CardScreenState extends State<CardScreen> {
//   late Razorpay razorpay;
//
//   @override
//   void initState(){
//     super.initState();
//     razorpay = Razorpay();
//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var screenSize = MediaQuery.of(context).size;
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFF15203D),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFF15203D),
//           title: Text(widget.productName, style: const TextStyle(color: Colors.white)),
//           centerTitle: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(14.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Product Image
//               Container(
//                 width: double.infinity,
//                 height: screenSize.height * 0.4,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(7),
//                   image: widget.imageUrl.isNotEmpty
//                       ? DecorationImage(
//                     image: NetworkImage(widget.imageUrl),
//                     fit: BoxFit.cover,
//                   )
//                       : null,
//                   color: const Color(0xFF192544),
//                 ),
//                 child: widget.imageUrl.isEmpty
//                     ? const Center(child: Icon(Icons.image, size: 100))
//                     : null,
//               ),
//               SizedBox(height: screenSize.height * 0.03),
//               Text(
//                 widget.productName,
//                 style: TextStyle(
//                   fontSize: screenSize.width * 0.06,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.01),
//               Text(
//                 'Price: ₹${widget.price}',
//                 style: TextStyle(
//                   fontSize: screenSize.width * 0.05,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 width: 100,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     '20% off',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.01),
//               Text(
//                 'Description: ${widget.desc}',
//                 style: TextStyle(
//                   fontSize: screenSize.width * 0.05,
//                   color: Colors.grey,
//                 ),
//               ),
//               SizedBox(height: screenSize.height * 0.10),
//               ElevatedButton(
//                 onPressed: _startPayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF22395D),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: screenSize.width * 0.12,
//                     vertical: screenSize.height * 0.015,
//                   ),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//                 ),
//                 child: const Text(
//                   'Buy Now',
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _startPayment() async {
//     var options = {
//       'key': 'rzp_test_HenD7YeMcwJuEC',
//       'amount': (widget.price! * 100).toInt(),
//       'name': 'Niranjan Kumar',
//       'description': widget.productName,
//       'prefill': {
//         'contact': '9155077691',
//         'email': 'niranjanskedugaon@gmail.com',
//       },
//       'theme': {
//         'color': '#3399cc',
//       },
//     };
//
//     try {
//       razorpay.open(options);
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     try {
//       String? userId = FirebaseAuth.instance.currentUser?.uid;
//
//       if (userId == null) {
//         Fluttertoast.showToast(msg: "User not logged in.");
//         return;
//       }
//
//       String orderId = FirebaseFirestore.instance.collection('orders').doc().id;
//
//       await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
//         'orderId': orderId,
//         'productId': widget.productId,
//         'productName': widget.productName,
//         'price': widget.price,
//         'imageUrl': widget.imageUrl,
//         'paymentId': response.paymentId,
//         'userId': userId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OrderConfirmationScreen(orderId: orderId),
//         ),
//       );
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Failed to save order details: $e");
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     Fluttertoast.showToast(
//       msg: "Payment Failed! Error Code: ${response.code}, Message: ${response.message}",
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Fluttertoast.showToast(
//       msg: "External Wallet Selected: ${response.walletName}",
//     );
//   }
//
//   @override
//   void dispose() {
//     razorpay.clear();
//     super.dispose();
//   }
// }


// import 'dart:isolate';
//
// // Alag isolate ka kaam
// void heavyTask(SendPort sendPort) {
//   for (int i = 0; i < 1000000000; i++) {}
//   sendPort.send("Task Done!");
// }
//
// void main() async {
//   print("Start");
//
//   final receivePort = ReceivePort();
//
//   await Isolate.spawn(heavyTask, receivePort.sendPort);
//
//   receivePort.listen((message) {
//     print(message);
//     receivePort.close();
//   });
//
//   print("End");
// }

//
// void heavyTask() {
//   for (int i = 0; i < 1000000000; i++) {} // Heavy work
//   print("Task Done");
// }
//
// void main() {
//   print("Start");
//   heavyTask(); // App block ho gayi yaha
//   print("End");
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CardScreen extends StatefulWidget {
  final String sellerId;
  final String productId;
  final String imageUrl;
  final String productName;
  final double? price;
  final String desc;
  final String orderId;

  const CardScreen({
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
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
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
                    onPressed: _startPayment,
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
        'status': 0,
        'seller_Id': widget.sellerId,
      });

      Fluttertoast.showToast(msg: "Order Successful");
      Navigator.pop(context);
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

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
}


