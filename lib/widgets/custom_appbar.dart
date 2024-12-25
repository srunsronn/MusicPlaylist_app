import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function? onBackPressed;

  const CustomAppBar({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: Image.asset(
            "assets/music_logoV4.png",
            height: 80,
          ),
        ),
      ),
      actions: const [
        SizedBox(
          width: 40,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
