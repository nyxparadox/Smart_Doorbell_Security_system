


import 'dart:math';

import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Presentation/home/screen/auth/SignUp_screens/otp_verification_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';


class SMTPEmailOTP {
  static const String username = 'rohitxxsingh7@gmail.com';
  static const String password = 'iszujpxtevqxpzrm'; // Gmail App Password
  static Map<String, String> _otpStorage = {};
  
  // Generate OTP
  static String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  // Send OTP via SMTP
  static Future<bool> sendEmailOTP(String email) async {
    try {
      String otp = generateOTP();
      _otpStorage[email] = otp;
      
      final smtpServer = gmail(username, password);
      
      final message = Message()
        ..from = Address(username, 'DoorSnap App')
        ..recipients.add(email)
        ..subject = 'Your Verification Code - DoorSnap'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #3469c4;">Email Verification</h2>
            <p>Hello,</p>
            <p>Your verification code for DoorSnap is:</p>
            <div style="background-color: #f0f0f0; padding: 20px; text-align: center; margin: 20px 0;">
              <h1 style="font-size: 32px; color: #007bff; margin: 0;">$otp</h1>
            </div>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn't request this verification, please ignore this email.</p>
            <hr>
            <p style="color: #666; font-size: 12px;">This is an automated message from DoorSnap App.</p>
          </div>
        ''';
      
      final sendReport = await send(message, smtpServer);
      print('Email sent successfully: ${sendReport.toString()}');
      return true;
      
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
  
  // Verify OTP
  static bool verifyEmailOTP(String email, String enteredOtp) {
    String? storedOtp = _otpStorage[email];
    if (storedOtp != null && storedOtp == enteredOtp) {
      _otpStorage.remove(email);
      return true;
    }
    return false;
  }
  
  // Get stored OTP (for debugging)
  static String? getStoredOTP(String email) {
    return _otpStorage[email];
  }
}

class EmailPhoneScreen extends StatefulWidget {
  EmailPhoneScreen({super.key});

  @override
  State<EmailPhoneScreen> createState() => _EmailPhoneScreenState();
}

class _EmailPhoneScreenState extends State<EmailPhoneScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone validation (basic)
  bool _isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  // Function to send email OTP
  Future<bool> _sendEmailOtp() async {
    try {
      return await SMTPEmailOTP.sendEmailOTP(_emailController.text.trim());
    } catch (e) {
      print("Error sending email OTP: $e");
      return false;
    }
  }

  // Function to send phone OTP (placeholder - we can implement SMS service later)
  Future<bool> _sendPhoneOtp() async {
    try {
      // For now, we'll simulate sending phone OTP
      // You can implement actual SMS service here later
      await Future.delayed(Duration(seconds: 1));
      print("Phone OTP sent successfully to ${_phoneController.text}");
      return true;
    } catch (e) {
      print("Error sending phone OTP: $e");
      return false;
    }
  }

  // Main function to send OTP
  Future<void> _sendOtp() async {
    // Validate inputs first
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter your email address", Colors.red);
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar("Please enter your phone number", Colors.red);
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar("Please enter a valid email address", Colors.red);
      return;
    }

    if (!_isValidPhone(_phoneController.text.trim())) {
      _showSnackBar("Please enter a valid 10-digit phone number", Colors.red);
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Send email OTP
      print("Sending email OTP to: ${_emailController.text.trim()}");
      final emailResult = await _sendEmailOtp();
      
      // Send phone OTP (placeholder)
      final phoneResult = await _sendPhoneOtp();

      if (emailResult && phoneResult) {
        _showSnackBar("OTP sent successfully to email and phone!", Colors.green);
        
        // Small delay to show success message
        await Future.delayed(Duration(milliseconds: 800));

        String phone = _phoneController.text.trim();
        String formattedPhone = phone.startsWith("+91") ? phone : "+91$phone";

        
        // Navigate to OTP verification screen
        getIt<AppRouter>().push(
          OtpVerificationScreen(
            email: _emailController.text.trim(),
            phone: formattedPhone,
          )
        );
      } else if (emailResult && !phoneResult) {
        _showSnackBar("Email OTP sent, but phone OTP failed", Colors.orange);
        // You can still navigate if email OTP is sent
        await Future.delayed(Duration(milliseconds: 800));
        getIt<AppRouter>().push(
          OtpVerificationScreen(
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
          )
        );
      } else if (!emailResult && phoneResult) {
        _showSnackBar("Phone OTP sent, but email OTP failed", Colors.orange);
      } else {
        _showSnackBar("Failed to send OTP. Please try again.", Colors.red);
      }
    } catch (e) {
      _showSnackBar("An error occurred. Please try again.", Colors.red);
      print("Error in _sendOtp: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function to show snackbar messages
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
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('SignUP ', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 52, 105, 196),
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Color.fromARGB(255, 192, 203, 209)),

          padding: const EdgeInsets.only(left: 25, right: 25),

          child: Center(
            child: Container(
              width: double.infinity,
              height: 800,
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              padding: const EdgeInsets.only(
                top: 50,
                bottom: 50,
                left: 25,
                right: 25,
              ),

              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(),
                      child: ClipOval(
                        child: Image.asset("assets/images/3d_signUp.png"),
                      ),
                    ),

                    Text(
                      "Please enter your email and phone number to continue.",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorText:
                            _emailController.text.isNotEmpty &&
                                !_isValidEmail((_emailController.text.trim()))
                            ? "Please enter valid email address"
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 40),

                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: "Phone (10 digits)",
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        errorText:
                            _phoneController.text.isNotEmpty &&
                                !_isValidPhone(_phoneController.text.trim())
                            ? 'Please enter a valid 10-digit phone number'
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 80),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp, // Call the actual send OTP function
                      child: _isLoading 
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
                              Text(
                                "Sending OTP...",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ],
                          )
                        : Text(
                            "Send OTP",
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading 
                          ? Colors.grey 
                          : const Color.fromARGB(255, 38, 79, 151),
                        minimumSize: Size(260, 65),
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



//==================================UPDATED CODE=======================================================

