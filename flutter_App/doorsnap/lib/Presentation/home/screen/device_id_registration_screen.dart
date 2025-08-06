import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Presentation/home/home_page.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:flutter/material.dart';

class DeviceIdRegistrationScreen extends StatefulWidget {
  const DeviceIdRegistrationScreen({super.key});

  @override
  State<DeviceIdRegistrationScreen> createState() =>
      _DeviceIdRegistrationScreenState();
}

class _DeviceIdRegistrationScreenState
    extends State<DeviceIdRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 192, 203, 209),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(25),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Enter your device ID to link your device'),

                    const SizedBox(height: 10,),

                    TextField(
                      
                      decoration: InputDecoration(
                        labelText: 'Device ID',
                        prefixIcon: Icon(Icons.linked_camera_rounded),
                        border: OutlineInputBorder(
                          
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 20,),

                    ElevatedButton(
                      onPressed: () => getIt<AppRouter>().push(const HomePage()),
                      child: Text('Link', style: TextStyle(color: Colors.white, fontSize: 23)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        minimumSize: Size(200, 57),
                        elevation: 3
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
