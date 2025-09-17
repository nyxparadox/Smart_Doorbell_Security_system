import 'dart:async';
import 'dart:ui';
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Presentation/home/screen/aboutUsPage.dart';
import 'package:doorsnap/Presentation/home/screen/auth/login_screen.dart';
import 'package:doorsnap/Presentation/home/screen/user_profile_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userDeviceId;
  String? _fullName;
  String? _phoneNumber;
  bool _isLoading = true;
  String? _profileImageUrl;

  StreamSubscription<DocumentSnapshot>? _userDataSubscription; 

  @override
  void initState() {
    super.initState();
    _getUserDeviceId();
    _getUserInformation();
    _getToken();
    _setupUserDataListener();
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel(); // Cancel subscription
    super.dispose();
  }


  void _setupUserDataListener() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _userDataSubscription = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            _fullName = data['fullName'] ?? '';
            _phoneNumber = data['phoneNumber'] ?? '';
            _profileImageUrl = data['profileImageUrl']; // This will update automatically
          });
        }
      }, onError: (error) {
        print('Error listening to user data: $error');
      });
    }
  }

    

  Future<void> _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Device FCM Token: $token");    
  }

  

  // we here take the current user's deviceId from their user document
  Future<void> _getUserDeviceId() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userDeviceId = userDoc.data()?['deviceId'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('User data not found');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading user data: $e');
    }
  }

  // Fetch additional user information

  Future<void> _getUserInformation() async {
  final currentUser = _auth.currentUser;
  if (currentUser != null) {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _fullName = data?['fullName'] ?? '';
          _phoneNumber = data?['phoneNumber'] ?? '';
          _profileImageUrl = data?['profileImageUrl']; // Load from Firestore
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user info: $e');
    }
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Format timestamp for display
  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return 'Today, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week - show day and time
      return DateFormat('EEEE, HH:mm').format(dateTime);
    } else {
      // Older - show full date
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    }
  }

  // Navigate to full image view
  void _showFullImage(String imageUrl, String timestamp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullImageView(imageUrl: imageUrl, timestamp: timestamp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DoorSnap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:  Color.fromARGB(255, 16, 56, 141),
        elevation: 0,
        centerTitle: true,


        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        


        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _getUserDeviceId();
            },
          ),
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: const EdgeInsets.only(left: 20, top: 10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 26, 70, 165),
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 16, 56, 141), Color.fromARGB(255, 14, 118, 170)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
               )
              ),
              child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                   radius: 40,
                   backgroundImage: _profileImageUrl == null || _profileImageUrl!.isEmpty
                       ? const NetworkImage('https://www.tenforums.com/attachments/user-accounts-family-safety/322690d1615743307-user-account-image-log-user.png')
                       : NetworkImage(_profileImageUrl!) as ImageProvider,
                  ),
                  Text("$_fullName", style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text("$_phoneNumber", style: TextStyle(color: Colors.grey.shade300))
               ],
             ),
            ),            
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('My Profile'),
              onTap: () => getIt<AppRouter>().push(const UserProfileScreen())
                
              
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to settings page
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About Us'),
              onTap: () => getIt<AppRouter>().push(const AboutUsPage())
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => getIt<AppRouter>().pushReplacement(const LoginScreen()),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 52, 105, 196),
              ),
            )
          : _userDeviceId == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Device not configured',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please configure your ESP32 device',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 240, 245, 255),
                    Color.fromARGB(255, 220, 230, 245),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Visitors',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 52, 105, 196),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Device: $_userDeviceId',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //                       Visitors List
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('visitors')
                          .where('deviceId', isEqualTo: _userDeviceId)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 52, 105, 196),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No visitors yet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Your ESP32 camera will capture\nvisitor images automatically',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final visitors = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: visitors.length,
                          itemBuilder: (context, index) {
                            final visitorData =
                                visitors[index].data() as Map<String, dynamic>;
                            final imageUrl = visitorData['imageUrl'] ?? '';
                            final timestamp =
                                visitorData['timestamp'] as Timestamp;
                            final formattedTime = _formatTimestamp(timestamp);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Material(
                                borderRadius: BorderRadius.circular(20),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.1),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.7),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: InkWell(
                                        onTap: () => _showFullImage(
                                          imageUrl,
                                          formattedTime,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Visitor Image
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: Colors.grey,
                                                            size: 30,
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              // Visitor Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Visitor Detected',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                          255,
                                                          52,
                                                          105,
                                                          196,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      formattedTime,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.green
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'New',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Arrow Icon
                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Color.fromARGB(
                                                  255,
                                                  52,
                                                  105,
                                                  196,
                                                ),
                                                size: 16,
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
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Full Image View Screen
class FullImageView extends StatelessWidget {
  final String imageUrl;
  final String timestamp;

  const FullImageView({
    super.key,
    required this.imageUrl,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(timestamp, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
