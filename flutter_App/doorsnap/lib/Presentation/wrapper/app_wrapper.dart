import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:doorsnap/Logics/cubit/auth_state.dart';
import 'package:doorsnap/Presentation/home/home_page.dart';
import 'package:doorsnap/Presentation/home/screen/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    
    getIt<AuthCubit>().checkAuthenticationStatus();    // Checking authentication status when app starts evrytime
  }

  @override
  Widget build(BuildContext context) {                
    return BlocBuilder<AuthCubit, AuthState>(           
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.loading:
          case AuthStatus.initial:
            return _buildSplashScreen();
          
          case AuthStatus.authenticated:
            return const HomePage();
          
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 16, 56, 141),
              Color.fromARGB(255, 14, 118, 170)
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/DOORSNAP_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.home_outlined,
                      size: 60,
                      color: Color.fromARGB(255, 16, 56, 141),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            
            const Text(
              'DoorSnap',             // App Name
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            
            Text(
              'Smart Way to See Who\'s at Your Door',       // Application tagline
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}