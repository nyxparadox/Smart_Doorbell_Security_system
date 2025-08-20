import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us", style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 52, 105, 196),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo & App Name
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/DOORSNAP_logo.png"), // your logo
            ),
            const SizedBox(height: 12),
            const Text(
              "DoorSnap",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // App Description
            const Text(
              "DoorSnap is a smart visitor monitoring app designed "
              "to keep your home safe and connected.\n\n"
              " Capture images of visitors in real-time.\n"
              " Store and view visitor logs securely in the cloud.\n"
              " Affordable, DIY-friendly home security solution.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const Spacer(),

            // Contact Info
            const Text(
              "Contact us: support@doorsnap.com",
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 5),
            const Text(
              "Version 1.0.0",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
