import 'dart:developer';

import 'package:doorsnap/Data/Repository/auth_repository.dart';
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Presentation/home/screen/auth/SignUp_screens/password_setup_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:flutter/material.dart';

class UserDetailsSetupScreen extends StatefulWidget {
  UserDetailsSetupScreen({super.key});

  @override
  State<UserDetailsSetupScreen> createState() => _UserDetailsSetupScreenState();
}

class _UserDetailsSetupScreenState extends State<UserDetailsSetupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  

  Future<void> handelAccountDetails() async {

    if (_fullNameController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter your full name', ) , backgroundColor: Colors.red));
      return;
    }

    if (_usernameController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('create your username'), backgroundColor: Colors.red));
      return;
    }

    try{
      final usernameExit = await getIt<AuthRepository>().checkUsernameExists(_usernameController.text);
      if (usernameExit == true){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('username already exist. please try making other username'), backgroundColor: Colors.red,));
        return;

      }
    }catch(e){
      print('Exeption: ${e.toString()}');
    }

    

    if (_addressController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enter your address'), backgroundColor: Colors.red));
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      await getIt<AuthCubit>().userDetails(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        address: _addressController.text,
      );

      getIt<AppRouter>().push(PasswordSetupScreen());
      
    } catch (e) {
      log(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  

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
                      controller: _fullNameController,
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
                      controller: _usernameController,
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
                      controller: _addressController,
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
                      onPressed: _isLoading ? null : handelAccountDetails,
                      child: _isLoading ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                      : Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading ? Colors.grey: const Color.fromARGB(255, 38, 79, 151),
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

}
