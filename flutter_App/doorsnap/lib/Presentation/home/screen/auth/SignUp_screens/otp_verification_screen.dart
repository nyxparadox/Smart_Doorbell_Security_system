import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignUP", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 105, 196),
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 192, 203, 209),
          ),
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
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  )
                ]
              ),
              padding: const EdgeInsets.only( bottom: 50, left: 25, right: 25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,                        
                      ),

                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/EnterOtp.png',
                          fit: BoxFit.cover,                          
                        ),
                      ),                    
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text("Verification Code", style: TextStyle(fontSize: 21),),

                          ],
                        ),
                      ],
                    ),

                    Text("we have sent you verification code on your email address and phone number.",
                    style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 65,),

                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "email otp",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18)
                        )
                      ),
                    ),

                    const SizedBox(height: 30,),

                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "phone otp",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          
                        )
                      ),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(onPressed: (){},
                     child: Text("Verify",
                      style: TextStyle(
                        color: Colors.white, fontSize: 21,
                         fontWeight: FontWeight.bold
                        ),                    
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                        minimumSize: Size(300, 60 )
                        

                      ),
                      
                    )

                  ],

                
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}