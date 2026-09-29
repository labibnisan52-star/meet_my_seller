import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Primary_AppBar extends StatelessWidget implements PreferredSizeWidget {
  const Primary_AppBar({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary:
          false, 
      backgroundColor: const Color(0xFFFFD700),
      elevation: 0,
      centerTitle: false,
      title: Text(
        "MeetMyProduct",
        style: GoogleFonts.inter(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.search, color: textColor, size: 26),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, color: textColor, size: 26),
            ),
            Positioned(
              right: 10,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings, color: textColor, size: 26),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
