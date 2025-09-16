
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Logics/cubit/auth_state.dart';
import 'package:doorsnap/Presentation/home/home_page.dart';
import 'package:doorsnap/Presentation/home/screen/auth/SignUp_screens/email_phone_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  

  Future<void> handleSignIn()async{
    FocusScope.of(context).unfocus();
  if (_emailController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please Enter your email address', ) , backgroundColor: Colors.red));
      return;
    }

  if (_passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter your Account Password', ) , backgroundColor: Colors.red));
      return;
    }

  if (!_isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email address', ) , backgroundColor: Colors.red));
      return;
    }

  

      // start loading
      setState(() {
        _isLoading = true;
      });
      try {
        await getIt<AuthCubit>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final authState = getIt<AuthCubit>().state;
        if (authState.status == AuthStatus.authenticated && authState.user != null) {
          await getIt<AppRouter>().pushReplacement(HomePage());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error ?? 'Login failed'), backgroundColor: Colors.red,),
          );
        }

      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      // stop loading
      setState(() {
        _isLoading = false;
      });
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 192, 203, 209),
        child: SafeArea(
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 100),
              child: Container(
                // Use MediaQuery to make it responsive
                height: MediaQuery.of(context).size.height - 
                       MediaQuery.of(context).padding.top - 300,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ]
                ),
            
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //  image will be added here
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/DOORSNAP_logo.png',      // image path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 7),
                      Text(
                        "DoorSnap",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
            
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Welcome!", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                        ],
                      ),
            
            
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Login to continue",
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      TextField(
                        
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          errorText:
                            _emailController.text.isNotEmpty &&
                                !_isValidEmail((_emailController.text.trim()))
                            ? "Please enter valid email address"
                            : null,
                        ),
                        onChanged: (value) => setState(() {
                        }),
                      ),


                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
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
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : handleSignIn, // Call the actual send OTP function
                      child: _isLoading 
                        ?  Row(
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
                                "Login...",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ) 
                        : Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(300 , 60),
                          backgroundColor: const Color.fromARGB(255, 38, 79, 151),
                          shadowColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  getIt<AppRouter>().push( EmailPhoneScreen());
                                  // Navigate to Sign Up screen
                                },
                            ),
                          ],
                        ),
                      ),
                      Padding(padding:  const EdgeInsets.only(bottom: 40)),
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