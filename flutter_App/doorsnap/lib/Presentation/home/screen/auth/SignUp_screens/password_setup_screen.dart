import 'package:flutter/material.dart';

class PasswordSetupScreen extends StatefulWidget {
  const PasswordSetupScreen({super.key});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 52, 105, 196),
      ),

      body: Container(
        color: const Color.fromARGB(255, 192, 203, 209),

        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: 800,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 7,
                      spreadRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              
                padding: const EdgeInsets.all(10),
              
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      child: ClipOval(
                        child: Image.asset("assets/images/password_protect.png"),
                      ),
                    ),
              
                    const SizedBox(height: 20),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Secure your account with strong password.",
                          style: TextStyle(color: Colors.blueGrey, fontSize: 17),
                        ),
                      ],
                    ),
              
                    const SizedBox(height: 40),
              
                    TextField(
                      decoration: InputDecoration(
                        label: Text("password"),
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 20),
              
                    TextField(
                      decoration: InputDecoration(
                        label: Text("confirm password"),
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 40),
              
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Create",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                        minimumSize: Size(300, 65)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
