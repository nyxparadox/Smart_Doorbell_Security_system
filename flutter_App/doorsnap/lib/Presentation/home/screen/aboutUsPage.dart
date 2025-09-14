import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Social URLs - Made static const for better performance
  static const String instagramUrl = "https://www.instagram.com/_rohit.7__?igsh=NzJsdnFxNGt0N3dz";
  static const String githubUrl = "https://github.com/nyxparadox";
  static const String linkedinUrl = "https://www.linkedin.com/in/rohit-singh-nyx";
  static const String supportEmail = "support@doorsnap.com";

  // Helper to launch URLs 
  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 16, 56, 141),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroSection(context)),
          SliverToBoxAdapter(child: _buildFeaturesSection()),
          SliverToBoxAdapter(child: _buildMissionSection()),
          SliverToBoxAdapter(child: _buildTeamSection()),
          SliverToBoxAdapter(child: _buildContactSection()),
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 16, 56, 141), Color.fromARGB(255, 14, 118, 170)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isTablet ? 60 : 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/DOORSNAP_logo.png",
                  width: isTablet ? 100 : 80,
                  height: isTablet ? 100 : 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.home_outlined,
                      size: isTablet ? 50 : 40,
                      color: const Color(0xFF2563EB),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "DoorSnap",
            style: TextStyle(
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "‘Smart Way to See Who’s at Your Door.’",
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Why Choose DoorSnap?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureItem(Icons.camera_alt_outlined, "Real-Time Capture", "Instantly capture visitors"),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.cloud_outlined, "Cloud Storage", "Secure visitor logs"),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.security_outlined, "Smart Security", "Intelligent monitoring"),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.smartphone_outlined, "Mobile Access", "Monitor from anywhere"),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF2563EB)),
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
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Our Mission",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "At DoorSnap, we believe home security should be accessible and intelligent. "
            "Our mission is to empower homeowners with smart visitor monitoring technology "
            "that provides peace of mind.",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Meet the Developer",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Rohit Singh",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Full Stack Developer & Founder",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildSocialIcons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    final socialLinks = [
      {
        'icon': Icons.camera_alt,
        'url': instagramUrl,
        'color': const Color(0xFFE4405F),
      },
      {
        'icon': Icons.work_outline,
        'url': linkedinUrl,
        'color': const Color(0xFF0A66C2),
      },
      {
        'icon': Icons.code,
        'url': githubUrl,
        'color': const Color(0xFF24292F),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialLinks.map((social) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            color: social['color'] as Color,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchURL(social['url'] as String),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  social['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            "Get in Touch",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _launchURL("mailto:$supportEmail"),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email_outlined, color: Color(0xFF2563EB), size: 20),
                  SizedBox(width: 8),
                  Text(
                    supportEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Text(
            "DoorSnap © 2025",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Version 2.11.04",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}