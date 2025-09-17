import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsnap/Data/Repository/profile_image_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userDeviceId;
  String? _fullName;
  String? _username;
  String? _address;
  String? _phoneNumber;
  String? _email;
  String? _uploadedImageUrl;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _getUserInformation(); // This will load profile image from Firestore
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  final uploader = CloudinaryImageUploader(
    cloudName: 'dytuvjwqu',
    uploadPreset: 'DoorSnap_users_profile_image',
  );

  
  Future<void> _onImageUploaded(String imageUrl) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Save to Firestore
        await _firestore.collection('users').doc(currentUser.uid).update({
          'profileImageUrl': imageUrl,
          'profileUpdatedAt': Timestamp.now(),
        });

        // Update local state
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        print('Error saving profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

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
            _fullName = data?['fullName'] ?? 'User';
            _username = data?['username'] ?? '';
            _address = data?['address'] ?? 'No address provided';
            _phoneNumber = data?['phoneNumber'] ?? 'No phone provided';
            _email = data?['email'] ?? currentUser.email ?? 'No email';
            _userDeviceId = data?['deviceId'] ?? 'No device ID';
            _uploadedImageUrl = data?['profileImageUrl']; // Load from Firestore
          });
        }
      } catch (e) {
        print('Error loading user info: $e');
      }
    }
  }


  void _onEditImageTap() async {
    setState(() {
      _isLoading = true;
    });

    final imageUrl = await uploader.pickAndUploadImage();
    if (imageUrl != null) {
      await _onImageUploaded(imageUrl);
    } else {
      print('Image upload canceled or failed');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, isTablet),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildProfileHeader(theme, isTablet),
                    _buildProfileStats(theme, isTablet),
                    _buildActionButtons(theme, isTablet),
                    _buildProfileDetails(theme, isTablet),
                    const SizedBox(height: 100),                 // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isTablet) {
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
              Color.fromARGB(255, 16, 56, 141), Color.fromARGB(255, 14, 118, 170)
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptionsBottomSheet(context),
          ),
        ),
      ],
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 16, 56, 141), Color.fromARGB(255, 14, 118, 170)
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 60 : 24,
        20,
        isTablet ? 60 : 24,
        40,
      ),
      child: Column(
        children: [
          Hero(
            tag: 'profile_image',
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: isTablet ? 70 : 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: isTablet ? 66 : 56,
                      backgroundImage: _uploadedImageUrl == null || _uploadedImageUrl!.isEmpty
                          ? const NetworkImage('https://www.tenforums.com/attachments/user-accounts-family-safety/322690d1615743307-user-account-image-log-user.png')
                          : NetworkImage(_uploadedImageUrl!),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _onEditImageTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF667EEA),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF667EEA),
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            _fullName ?? 'Loading...',
            style: TextStyle(
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            _username?.isNotEmpty == true ? '@$_username' : '',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Engineers are the wizards who bring imagination to life.",
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.white.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(ThemeData theme, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 24,
        vertical: 20,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      
    );
  }


  Widget _buildActionButtons(ThemeData theme, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                      // Navigate to edit profile
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 16, 56, 141),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
        ],
      ),
    );
  }

  Widget _buildProfileDetails(ThemeData theme, bool isTablet) {
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
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ModernProfileDetailCard(
            icon: Icons.email_outlined,
            title: 'Email Address',
            detail: _email ?? 'Loading...',
            onEdit: () => _editField('email'),
          ),
          ModernProfileDetailCard(
            icon: Icons.phone_outlined,
            title: 'Phone Number',
            detail: _phoneNumber ?? 'Loading...',
            onEdit: () => _editField('phone'),
          ),
          ModernProfileDetailCard(
            icon: Icons.location_on_outlined,
            title: 'Address',
            detail: _address ?? 'Loading...',
            onEdit: () => _editField('address'),
          ),
          ModernProfileDetailCard(
            icon: Icons.devices_outlined,
            title: 'Device ID',
            detail: _userDeviceId ?? 'Loading...',
            onEdit: () => _editField('deviceId'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  void _editField(String fieldType) {
    // Here we will Implement field editing logic in future
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit $fieldType functionality coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notification Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security_outlined),
              title: const Text('Security Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_outdoor_outlined),
              title: const Text('Device Management'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ModernProfileDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onEdit;
  final bool isLast;

  const ModernProfileDetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onEdit,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
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
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF667EEA),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}