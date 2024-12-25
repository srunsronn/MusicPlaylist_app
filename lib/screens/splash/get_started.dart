import 'package:flutter/material.dart';
import 'package:auth_firebase/screens/auth/signin.dart';
import 'package:auth_firebase/widgets/custom_button.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF00C2CB), // Use const for better performance
      body: Stack(
        children: [
          // Background image container
          Image.asset(
            "assets/img_girl.png",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height * 0.5, // Adjust height
          ),
          // Black container for text and button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black, // Moved the color here
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Take minimum space
                children: [
                  Image.asset(
                    "assets/music_logoV4.png",
                    width: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "From the latest to the greatest hits, play your favorite tracks on musium now!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      // textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Custom Button
                  CustomButton(
                    title: "Get Started",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const Signin(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40), // Space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
