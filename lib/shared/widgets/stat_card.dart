import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color? color;
  const StatCard({super.key, this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: color, size: 32, semanticLabel: label) : null,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
} 