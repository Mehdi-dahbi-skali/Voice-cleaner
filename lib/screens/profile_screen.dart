import 'package:flutter/material.dart';
import '../models/audio_item.dart';

/// Profile Screen
/// 
/// Full implementation of user profile with stats and recent activity
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample mock data for stats
    final totalRecordings = 24;
    final totalDuration = "2h 15m";
    final storageUsed = "156 MB";

    // Sample mock data for recent recordings
    final recentAudios = [
      AudioItem(
        id: '1',
        title: 'Morning Meeting',
        duration: const Duration(minutes: 5, seconds: 20),
        date: DateTime.now(),
        type: 'cleaned',
      ),
      AudioItem(
        id: '2',
        title: 'Project Ideas',
        duration: const Duration(minutes: 2, seconds: 45),
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'original',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // User Avatar & Info
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ait Be',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'aitbe@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 32),
            
            // Statistics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard('Recordings', totalRecordings.toString(), Icons.mic),
                  const SizedBox(width: 12),
                  _buildStatCard('Total Time', totalDuration, Icons.timer),
                  const SizedBox(width: 12),
                  _buildStatCard('Storage', storageUsed, Icons.storage),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Recordings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            
            // List of recent recordings
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentAudios.length,
              itemBuilder: (context, index) {
                final audio = recentAudios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.graphic_eq, color: Colors.blue),
                    ),
                    title: Text(audio.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${audio.formattedDate} • ${audio.formattedDuration}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

