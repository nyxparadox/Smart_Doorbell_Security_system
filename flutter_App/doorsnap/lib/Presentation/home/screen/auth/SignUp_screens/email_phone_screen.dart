import 'package:flutter/material.dart';

class EmailPhoneScreen extends StatefulWidget {
  const EmailPhoneScreen({super.key});

  @override
  State<EmailPhoneScreen> createState() => _EmailPhoneScreenState();
}

class _EmailPhoneScreenState extends State<EmailPhoneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUP '),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Step 1',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
    
      ),

      body: Center(
        child: Text(
          'Email and Phone Number ',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
      
    );
  }
}