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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('SignUP ',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        
    
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 192, 203, 209),
          ),

          padding: const EdgeInsets.only( left: 25, right: 25),

          child: Center(
            child: Container(
              width: double.infinity,
              height: 800,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ]
              ),
            
              padding: const EdgeInsets.only(top: 50, bottom: 50, left: 25, right: 25),
            
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Step 1.",
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                    
                    Text("Please enter your email and phone number to continue.",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                
                    const SizedBox(height: 40),
                
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),                      
                    ),
                
                    const SizedBox(height: 40),
                
                    TextField(
                      keyboardType: TextInputType.number,                      
                      decoration: InputDecoration(
                        labelText: "Phone",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)
                        )
                      ),
                      
                    ),
                
                    const SizedBox(height: 80),
                
                    ElevatedButton(onPressed: (){},
                     child: Text("Next",
                      style: TextStyle(fontSize: 22,color: Colors.white)),
                      
                     
                     style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                      minimumSize: Size(260, 65)
                      ),
                    ),
                
                    const SizedBox(height: 210,),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline),
                        Flexible(
                          child: Text(
                            "please gave your active email and phone number so our services can reach to you ",
                            style: TextStyle(color: Colors.grey, fontSize: 14),                            
                          ),
                        ),
                      ],
                    )               
                  ],
                ),
              ),              
            ),
          ),
        )
      ),     
    );
  }
}