import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A5545),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Inventory', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Inventory page', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
