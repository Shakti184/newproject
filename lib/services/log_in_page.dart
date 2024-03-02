import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newproject/components/helper.dart';
import 'package:newproject/services/forgot_password.dart';
import '../HomePage/home_page.dart';
import '../components/rounded_input_field.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200.0,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Image.asset(
                  'assets/logo.jpeg', // Replace with the actual image asset path
                  height: 200.0,
                  width: 200.0,
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  RoundedInputField(
                    labelText: 'Email',
                    obscureText: false,
                    borderRadius: 40.0,
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 16.0),
                  RoundedInputField(
                    labelText: 'Password',
                    obscureText: true,
                    borderRadius: 40.0,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const ForgotPassword()));
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      ElevatedButton(
                        onPressed: () {
                          _performLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.lightBlue,
                           // Change color as needed
                        ),
                        child: const Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                              (route) => false);
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

_performLogin() async {
  final String username = _usernameController.text;
  final String password = _passwordController.text;
  if (username == "" || password == "") {
    Helper.customAlertBox(context, "Enter The Required Fields");
  } else {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      ).then((value) {
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      Helper.customAlertBox(context, e.code.toString());
    }
  }
}

}
