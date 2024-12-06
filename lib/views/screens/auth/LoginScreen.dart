import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_app/views/screens/auth/RegisterScreen.dart';

import '../../../HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF15203D),
        appBar: AppBar(
          backgroundColor: Color(0xFF15203D),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.05),
              Text(
                'Hi, Welcome Back! 👋',
                style: TextStyle(
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,color: Colors.white
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              _buildTextField('Email', 'Enter Your Email', screenSize, emailController),
              SizedBox(height: screenSize.height * 0.02),
              _buildTextField('Password', 'Enter Your Password', screenSize, passwordController, isPassword: true),

              SizedBox(height: screenSize.height * 0.03),

              SizedBox(
                width: double.infinity,
                height: screenSize.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    loginAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.02),
                    child: Text(
                      'Or With',
                      style: TextStyle(fontSize: screenSize.width * 0.04,color: Colors.white),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildSocialButton('Login with Google', Colors.white, screenSize, isGoogle: true),
              SizedBox(height: screenSize.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: screenSize.width * 0.04,color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, Size screenSize,
      TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenSize.width * 0.04,color: Colors.white),
        ),
        SizedBox(height: screenSize.height * 0.005),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.height * 0.02,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenSize.width * 0.02,),
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
            ),
            suffixIcon: isPassword ? Icon(Icons.visibility_off,color: Colors.white,) : null,
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, Color color, Size screenSize, {bool isGoogle = false}) {
    return SizedBox(
      width: double.infinity,
      height: screenSize.height * 0.06,
      child: ElevatedButton.icon(
        onPressed: () {
          signInWithGoogle();
        },
        icon: isGoogle
            ? Image.asset(
          'assets/Google.png',
          height: screenSize.height * 0.03,
        )
            : Container(),
        label: Text(
          text,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            color: isGoogle ? Colors.black : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
          ),
        ),
      ),
    );
  }

  void signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(msg: "Google Sign-in canceled");
        return;
      }
      final GoogleSignInAuthentication googleAuthentication = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        User? currentUser = userCredential.user;
        await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
          "username": googleUser.displayName ?? "Google User",
          "loginMethod": "Google",
          "email": currentUser.email,
        }, SetOptions(merge: true));

        Fluttertoast.showToast(msg: "Google Sign-In Successful");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } catch (ex) {
      Fluttertoast.showToast(msg: "Error during Google Sign-In: $ex");
    }
  }

  void loginAccount() async {
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all the fields");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      if (userCredential.user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on FirebaseAuthException catch (ex) {
      Fluttertoast.showToast(msg: ex.message ?? "Login failed, please try again.");
    } catch (ex) {
      Fluttertoast.showToast(msg: "An unexpected error occurred.");
    }
  }
}
