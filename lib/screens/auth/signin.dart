import 'package:auth_firebase/models/user_model.dart';
import 'package:auth_firebase/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth_firebase/screens/auth/signup.dart';
import 'package:auth_firebase/widgets/custom_appbar.dart';
import 'package:auth_firebase/widgets/custom_button.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _handleSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      AppUser? user =
          await _firebaseService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnackBar('Sign-in failed. Please try again.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  void _googleSignIn() async {
    AppUser? user = await _firebaseService.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar('Sign-in with Google failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/get-started');
        },
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _signinText(),
                const SizedBox(height: 30),
                _emailField(),
                const SizedBox(height: 20),
                _passwordField(),
                const SizedBox(height: 30),
                _signinButton(),
                const SizedBox(height: 30),
                _orRow(),
                const SizedBox(height: 30),
                _socialSignInButtons(),
                const SizedBox(height: 30),
                _signUpPrompt(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signinText() {
    return const Text(
      'Sign In',
      style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Enter Email'),
      style: const TextStyle(color: Colors.white),
      validator: _validateEmail,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: const EdgeInsets.all(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        hintText: 'Enter Password',
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      style: const TextStyle(color: Colors.white),
      validator: _validatePassword,
    );
  }

  Widget _signinButton() {
    return CustomButton(title: "Sign In", onTap: _handleSignIn);
  }

  Widget _orRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey[500])),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text("OR", style: TextStyle(color: Colors.white)),
          ),
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _socialSignInButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _googleSignIn,
          icon: const Image(
            image: AssetImage('assets/google_logo.png'),
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () {
            print('Apple Sign-In');
          },
          icon: const Image(
            image: AssetImage('assets/apple_logo.png'),
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _signUpPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const Signup()),
            );
          },
          child: const Text('Sign Up',
              style: TextStyle(
                  color: Color(0xFFF00C2CB), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade800,
      contentPadding: const EdgeInsets.all(25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
    );
  }
}
