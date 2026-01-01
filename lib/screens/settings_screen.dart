import 'package:flutter/material.dart';
import '../login/login_screen.dart';

/// Settings Screen
/// 
/// Full implementation of settings based on Figma design style
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Setting states
  bool _notificationsEnabled = true;
  String _audioQuality = 'High';
  String _audioFormat = 'M4A';
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Recording'),
          _buildSettingTile(
            context,
            icon: Icons.high_quality,
            title: 'Audio Quality',
            subtitle: _audioQuality,
            onTap: () => _showSelectionDialog(
              'Audio Quality',
              ['Low', 'Medium', 'High'],
              (val) => setState(() => _audioQuality = val),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.audio_file,
            title: 'Audio Format',
            subtitle: _audioFormat,
            onTap: () => _showSelectionDialog(
              'Audio Format',
              ['M4A', 'MP3', 'WAV'],
              (val) => setState(() => _audioFormat = val),
            ),
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme for the app'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          _buildSettingTile(
            context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get notified when audio cleaning is done'),
            secondary: const Icon(Icons.notifications_active_outlined),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          _buildSectionHeader(context, 'Account'),
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'Sign Out',
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showLogoutConfirmation(context),
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            onTap: null,
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
    );
  }

  void _showSelectionDialog(String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $title'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => ListTile(
            title: Text(opt),
            onTap: () {
              onSelect(opt);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

