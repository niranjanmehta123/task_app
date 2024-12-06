
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/HomeScreen.dart';
import 'views/screens/auth/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF15203D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image.png', width: 150, height: 150),
          ],
        ),
      ),
    );
  }

  _checkLogin() async{

    await Future.delayed(const Duration(seconds: 2));

    String? auth = FirebaseAuth.instance.currentUser?.uid;
    if(!mounted) return;
    if(auth == null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginScreen(),));
    }else{

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  HomeScreen(),));
    }
  }

}
