import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  final Function(int) onSelect;

  const MenuSection({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 16, 130, 230),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () => onSelect(0),
            icon: const Icon(Icons.home_rounded, color: Colors.white, size: 52),
            label: const Text(
              "Home",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: 30),
          TextButton.icon(
            onPressed: () => onSelect(1),
            icon: const Icon(Icons.analytics_rounded, color: Colors.white, size: 50),
            label: const Text(
              "Analysis",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: 30),
          TextButton.icon(
            onPressed: () => onSelect(2),
            icon: const Icon(Icons.info_rounded, color: Colors.white, size: 46),
            label: const Text(
              "About",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}