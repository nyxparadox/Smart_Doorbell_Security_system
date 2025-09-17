
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Presentation/home/screen/auth/SignUp_screens/email_phone_screen.dart';
import 'package:doorsnap/Presentation/home/screen/auth/SignUp_screens/user_details_setup_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String  phone;


  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.phone,
    
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _emailOtpController = TextEditingController();
  
  bool _isVerifying = false;

  // Function to verify email OTP using SMTP
  Future<bool> _verifyEmailOtp() async {
    try {
      String enteredOtp = _emailOtpController.text.trim();
      bool isValid = SMTPEmailOTP.verifyEmailOTP(widget.email, enteredOtp);
      
      if (isValid) {
        print("Email OTP verified successfully");
        return true;
      } else {
        print("Email OTP verification failed");


        // Debug: Print stored OTP (remove in production) ------------------xxxxx----------------
        String? storedOtp = SMTPEmailOTP.getStoredOTP(widget.email);
        print("Debug - Stored OTP: $storedOtp, Entered OTP: $enteredOtp");
        return false;
      }
    } catch (e) {
      print("Error verifying email OTP: $e");
      return false;
    }
  }


  // Function to verify email OTPs
  Future<void> _verifyOtp() async {
  if (_emailOtpController.text.trim().isEmpty) {
    _showSnackBar("Please enter email OTP", Colors.red);
    return;
  }

  setState(() {
    _isVerifying = true;
  });

  try {
    final emailVerified = await _verifyEmailOtp();

    if (emailVerified) {
      _showSnackBar("OTP verified successfully!", Colors.green);
      await Future.delayed(Duration(milliseconds: 500));

      try {
        // Get FCM token before creating user
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        print("FCM Token obtained: $fcmToken");

        // Created user with FCM token
        await getIt<AuthCubit>().emailPhoneDetails(
          email: widget.email, 
          phoneNumber: widget.phone,
          fcmToken: fcmToken, // Pass the FCM token
        );

        getIt<AppRouter>().push(UserDetailsSetupScreen(email: widget.email));

      } catch(e) {
        _showSnackBar("${e.toString()}", Colors.red);
        print(e);
      }
    } else {
      _showSnackBar("Email OTP is incorrect", Colors.orange);
    }
  } catch (e) {
    _showSnackBar("Verification failed. Please try again.", Colors.red);
    print("Error in _verifyOtp: $e");
  } finally {
    setState(() {
      _isVerifying = false;
    });
  }
}

  // function for snackbars
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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

                    SizedBox(height: 10),

                    // Showing email and phone information
                    Text(
                      "OTP sent to:",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Email: ${widget.email}",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                    

                    const SizedBox(height: 50,),

                    TextField(
                      controller: _emailOtpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "Email OTP",
                        hintText: "Enter 6-digit code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18)
                        ),
                        counterText: "",                         // to Hide character counter
                      ),
                    ),

                    const SizedBox(height: 30,),

                   

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      child: _isVerifying 
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text("Verifying...",
                                style: TextStyle(
                                  color: Colors.white, fontSize: 21,
                                  fontWeight: FontWeight.bold
                                ),                    
                              ),
                            ],
                          )
                        : Text("Verify",
                            style: TextStyle(
                              color: Colors.white, fontSize: 21,
                              fontWeight: FontWeight.bold
                            ),                    
                          ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVerifying 
                          ? Colors.grey 
                          : const Color.fromARGB(255, 38, 79, 151),
                        minimumSize: Size(300, 60)
                      ),  
                    ),

                    SizedBox(height: 20),

                    // Debug info (removed  when app is fully developed )-----------xxxxxxxxxxxx-----------
                    if (widget.email.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          String? storedOtp = SMTPEmailOTP.getStoredOTP(widget.email);
                          if (storedOtp != null) {
                            _showSnackBar("Debug - Email OTP: $storedOtp", Colors.blue);
                          } else {
                            _showSnackBar("No OTP found for this email", Colors.orange);
                          }
                        },
                        child: Text(
                          "Debug: Show Email OTP",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    _emailOtpController.dispose();
    
    super.dispose();
  }
}