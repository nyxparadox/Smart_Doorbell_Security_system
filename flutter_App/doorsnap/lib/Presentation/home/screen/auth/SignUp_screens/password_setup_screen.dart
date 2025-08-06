
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Presentation/home/home_page.dart';
import 'package:doorsnap/Presentation/home/screen/device_id_registration_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';

class PasswordSetupScreen extends StatefulWidget {
  final String? email;
  const PasswordSetupScreen({super.key, this.email});

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  


  @override
  void dispose() {
  
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  
  
  String? _validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create your account password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    return null;
  }


  String? _validateConfirmPasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Password confirmation does not match';
    }
    return null;
  }


  Future<void> _handleAccountCreation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {

      // Geting the current user's email from state or widget parameter
      final authCubit = getIt<AuthCubit>();
      final currentState = authCubit.state;

      String? userEmail = widget.email ?? currentState.user?.email;

      if (userEmail == null || userEmail.isEmpty) {
        throw 'User email not found. Please restart the signup process.';
      }

       print('🔐 Linking email/password for: $userEmail');

       await authCubit.linkPasswordToAccount(
        email: userEmail,
        password: _passwordController.text,
      );
      //                       password saving process
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSuccessSnackBar('Password created successfully!');
        getIt<AppRouter>().push(const DeviceIdRegistrationScreen());
      }
    } catch (e) {
      if (mounted) {


        String errorMessage = 'Failed to create password. Please try again.';

        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'This email is already registered with a password.';
        } else if (e.toString().contains('User email not found')) {
          errorMessage = 'Session expired. Please start signup process again.';
        }
        
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  

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
              child: Form(
                key: _formKey,
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
                          child: Image.asset(
                            "assets/images/password_protect.png",
                          ),
                        ),
                      ),
                
                      const SizedBox(height: 20),
                
                      Row(
                        children: [
                          const Text(
                                  "Secure Your Account",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 52, 105, 196),
                                  ),
                                ),
                        ],
                      ),
                            const SizedBox(height: 8),
                            const Text(
                              "Create a strong password to protect your account and personal information.",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                
                      const SizedBox(height: 40),
                
                       // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              validator: _validatePasswordField,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 52, 105, 196),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                
                      const SizedBox(height: 20),
                
                      TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              validator: _validateConfirmPasswordField,
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 52, 105, 196),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                
                      const SizedBox(height: 40),
                
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleAccountCreation,
                        child: _isLoading ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                         : Text(
                          "Create",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                          elevation: 3,
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
      ),
    );
  }
}
