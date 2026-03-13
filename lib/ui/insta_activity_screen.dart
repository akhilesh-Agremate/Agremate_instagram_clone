import 'package:flutter/material.dart';

class InstaActivityScreen extends StatefulWidget {
  const InstaActivityScreen({Key? key}) : super(key: key);

  @override
  _InstaActivityScreenState createState() => _InstaActivityScreenState();
}

class _InstaActivityScreenState extends State<InstaActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Activity'),       // Added const
      ),
      body: const Center(                    // Added const
        child: Text('NOT IMPLEMENTED YET'),
      ),
    );
  }
}