import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryButton({
    required this.label,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          // Add gradient background for the selected button
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          // Add border for the unselected button
          border: isSelected
              ? null
              : Border.all(
                  width: 1.5,
                  color: Colors.grey, // Border color for unselected buttons
                ),
          borderRadius: BorderRadius.circular(30),
          color: isSelected
              ? null
              : Colors.transparent, // Transparent background for unselected
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.grey.shade400, // Text color
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
