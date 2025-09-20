import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Logics/cubit/auth_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String? _currentDeviceId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSettings();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUser = _auth.currentUser;
      
      if (currentUser != null) {            // set 
        setState(() {
          _notificationsEnabled = prefs.getBool('notifications_enabled_${currentUser.uid}') ?? true;
        });

        // Load current device ID
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists) {
          setState(() {
            _currentDeviceId = userDoc.data()?['deviceId'];
          });
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      setState(() {
        _notificationsEnabled = value;
        _isLoading = true;
      });

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled_${currentUser.uid}', value);

        if (value) {                // If notifications are enabled  - get and store FCM token
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await _firestore.collection('users').doc(currentUser.uid).update({
              'fcmToken': token,
              'notificationsEnabled': true,
            });
          }
        } else {   // if notification are set to diabele - remove FCM token from firestore
          await _firestore.collection('users').doc(currentUser.uid).update({
            'fcmToken': null,
            'notificationsEnabled': false,
          });
        }

        _showSnackBar(
          value ? 'Notifications enabled' : 'Notifications disabled',
          Colors.green,
        );
      }
    } catch (e) {
      print('Error toggling notifications: $e');
      _showSnackBar('Failed to update notification settings', Colors.red);
      setState(() {
        _notificationsEnabled = !value;             // Revert on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Set New password of user's account  

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isOldPasswordVisible = false;
    bool isNewPasswordVisible = false;
    bool isConfirmPasswordVisible = false;
    bool isChangingPassword = false;

    showDialog(                        // Show Dialog box for password change
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 16, 56, 141),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: !isOldPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isOldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isOldPasswordVisible = !isOldPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !isNewPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isNewPasswordVisible = !isNewPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChangingPassword ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isChangingPassword ? null : () async {
                if (oldPasswordController.text.isEmpty ||      //  Checking is any field is empty
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  _showSnackBar('Please fill all fields', Colors.red);
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  _showSnackBar('New passwords do not match', Colors.red);
                  return;
                }

                if (newPasswordController.text.length < 8) {
                  _showSnackBar('Password must be at least 8 characters', Colors.red);
                  return;
                }

                setState(() {
                  isChangingPassword = true;
                });

                try {
                  final user = _auth.currentUser;
                  if (user?.email != null) {
                    // Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email: user!.email!,
                      password: oldPasswordController.text,
                    );
                    await user.reauthenticateWithCredential(credential);

                    
                    await user.updatePassword(newPasswordController.text);    //// if everything okay than  Update password

                    Navigator.pop(context);
                    _showSnackBar('Password changed successfully', Colors.green);
                  }
                } catch (e) {
                  _showSnackBar('Failed to change password: ${e.toString()}', Colors.red);
                } finally {
                  setState(() {
                    isChangingPassword = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 16, 56, 141),
                foregroundColor: Colors.white,
              ),
              child: isChangingPassword
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }


//     Change Device ID of user's linked camera module 
  void _showChangeDeviceIdDialog() {
    final deviceIdController = TextEditingController();
    deviceIdController.text = _currentDeviceId ?? '';
    bool isUpdating = false;

    showDialog(                           // Show Dialog box for device ID setup/change
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Update Device ID',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 16, 56, 141),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your ESP32 camera device ID to link with your account.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: deviceIdController,
                decoration: InputDecoration(
                  labelText: 'Device ID',
                  prefixIcon: const Icon(Icons.camera_outdoor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating ? null : () async {
                if (deviceIdController.text.isEmpty) {
                  _showSnackBar('Please enter a device ID', Colors.red);
                  return;
                }

                setState(() {
                  isUpdating = true;
                });

                try {
                  await getIt<AuthCubit>().deviceIdDetails(
                    deviceId: deviceIdController.text.trim(),
                  );

                  this.setState(() {
                    _currentDeviceId = deviceIdController.text.trim();
                  });

                  Navigator.pop(context);
                  _showSnackBar('Device ID updated successfully', Colors.green);
                } catch (e) {
                  _showSnackBar('Failed to update device ID', Colors.red);
                } finally {
                  setState(() {
                    isUpdating = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 16, 56, 141),
                foregroundColor: Colors.white,
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }


//  Snackbar for showing messages
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isTablet),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSettingsSection(isTablet),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 16, 56, 141),
              Color.fromARGB(255, 14, 118, 170)
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSettingsSection(bool isTablet) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isTablet ? 60 : 24,
        24,
        isTablet ? 60 : 24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Change Password Setting
          _buildSettingCard(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: _showChangePasswordDialog,
          ),
          
          // Device Management Setting
          _buildSettingCard(
            icon: Icons.camera_outdoor_outlined,
            title: 'Device Management',
            subtitle: _currentDeviceId != null 
                ? 'Current: $_currentDeviceId' 
                : 'No device linked',
            onTap: _showChangeDeviceIdDialog,
          ),
          
          // Notification Settings
          _buildNotificationCard(),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 56, 141).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color.fromARGB(255, 16, 56, 141),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 16, 56, 141).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color.fromARGB(255, 16, 56, 141),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get notified when visitors are detected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeColor: const Color.fromARGB(255, 16, 56, 141),
                  ),
          ],
        ),
      ),
    );
  }
}