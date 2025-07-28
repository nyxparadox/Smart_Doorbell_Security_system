import 'package:flutter/material.dart';

class UserDetailsSetupScreen extends StatefulWidget {
  const UserDetailsSetupScreen({super.key});

  @override
  State<UserDetailsSetupScreen> createState() => _UserDetailsSetupScreenState();
}

class _UserDetailsSetupScreenState extends State<UserDetailsSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SetUP Account ", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 105, 196),
      ),

      body: Container(
        color: const Color.fromARGB(255, 192, 203, 209),

        padding: const EdgeInsets.only(left: 25, right: 25),

        child: Center(
          child: Container(
            width: double.infinity,
            height: 800,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, 3),
                  spreadRadius: 5,
                  blurRadius: 7,
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(shape: BoxShape.circle),

                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/Account_Details.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Account Details",
                          style: TextStyle(color: Colors.black87, fontSize: 23),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Please fill up these required fields for Account Setup.",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    TextField(
                      decoration: InputDecoration(
                        label: Text("full name"),
                        prefixIcon: Icon(Icons.account_circle_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      decoration: InputDecoration(
                        label: Text("username"),
                        prefixIcon: Icon(Icons.alternate_email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      decoration: InputDecoration(
                        label: Text("Address"),
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    ElevatedButton(
                      onPressed: () {},
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                        minimumSize: Size(300, 65),
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
