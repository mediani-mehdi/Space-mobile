import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A5545),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tasks', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tasks page', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}
