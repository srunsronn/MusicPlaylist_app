import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final VoidCallback onPressed;
  const GradientButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              colors: [
                Color(0xFFA6F3FF),
                Color(0xFF00C2CB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.rectangle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: icon,
            iconSize: 25,
            color: Colors.black, // Icon color
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ],
    );
  }
}
