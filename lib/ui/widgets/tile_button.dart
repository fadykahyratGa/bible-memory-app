import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool selected;

  const TileButton({super.key, required this.text, required this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
