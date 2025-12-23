import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import 'recording_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

/// Home Screen
/// 
/// Main screen showing audio recordings list and recording options
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected filter option: 'all', 'cleaned', 'original'
  String _selectedFilter = 'all';
  
  // Sample audio items (will be replaced with real data from backend)
  final List<AudioItem> _allAudios = [
    AudioItem(
      id: '1',
      title: 'Meeting Notes',
      duration: const Duration(minutes: 5, seconds: 32),
      date: DateTime(2024, 1, 15),
      type: 'cleaned',
    ),
    AudioItem(
      id: '2',
      title: 'Voice Memo',
      duration: const Duration(minutes: 2, seconds: 15),
      date: DateTime(2024, 1, 14),
      type: 'original',
    ),
    AudioItem(
      id: '3',
      title: 'Interview Recording',
      duration: const Duration(minutes: 12, seconds: 45),
      date: DateTime(2024, 1, 13),
      type: 'cleaned',
    ),
    AudioItem(
      id: '4',
      title: 'Quick Note',
      duration: const Duration(minutes: 1, seconds: 8),
      date: DateTime(2024, 1, 12),
      type: 'original',
    ),
    AudioItem(
      id: '5',
      title: 'Lecture Recording',
      duration: const Duration(minutes: 45, seconds: 30),
      date: DateTime(2024, 1, 10),
      type: 'cleaned',
    ),
  ];

  /// Get filtered audio items based on selected filter
  List<AudioItem> get _filteredAudios {
    if (_selectedFilter == 'all') {
      return _allAudios;
    }
    return _allAudios.where((audio) => audio.type == _selectedFilter).toList();
  }

  /// Handle filter selection
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  /// Handle play button press
  void _handlePlay(AudioItem audio) {
    // TODO: Implement play functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${audio.title}'),
      ),
    );
  }

  /// Handle share button press
  void _handleShare(AudioItem audio) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${audio.title}'),
      ),
    );
  }

  /// Handle delete button press
  void _handleDelete(AudioItem audio) {
    // TODO: Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleting: ${audio.title}'),
      ),
    );
  }

  /// Handle start recording button press
  void _handleStartRecording() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecordingScreen(),
      ),
    );
  }

  /// Handle view more button press
  void _handleViewMore() {
    // TODO: Navigate to full list screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View more feature coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mic logo
                  Icon(
                    Icons.mic,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Text(
                    'Voice Recorder',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Filter options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterButton('Cleaned', 'cleaned'),
                  _buildFilterButton('All', 'all'),
                  _buildFilterButton('Original', 'original'),
                ],
              ),
            ),

            // Audio list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredAudios.length + 1, // +1 for "View More" button
                itemBuilder: (context, index) {
                  if (index == _filteredAudios.length) {
                    // View More button
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TextButton(
                        onPressed: _handleViewMore,
                        child: const Text('View More'),
                      ),
                    );
                  }

                  final audio = _filteredAudios[index];
                  return _buildAudioItem(audio);
                },
              ),
            ),

            // "Your voice. Crystal clear." section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Your voice. Crystal clear.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleStartRecording,
                    icon: const Icon(Icons.mic, size: 24),
                    label: const Text(
                      'Start Recording',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// Build filter button
  Widget _buildFilterButton(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _selectFilter(filter),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
            foregroundColor: isSelected
                ? Colors.white
                : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: isSelected ? 2 : 0,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// Build audio item card
  Widget _buildAudioItem(AudioItem audio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              audio.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Duration and Date row
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  audio.formattedDuration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  audio.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete button
                IconButton(
                  onPressed: () => _handleDelete(audio),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Delete',
                ),
                // Share button
                IconButton(
                  onPressed: () => _handleShare(audio),
                  icon: const Icon(Icons.share_outlined),
                  color: Colors.blue,
                  tooltip: 'Share',
                ),
                // Play button
                IconButton(
                  onPressed: () => _handlePlay(audio),
                  icon: const Icon(Icons.play_arrow),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 32,
                  tooltip: 'Play',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Home is selected
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              // Navigate to recording screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecordingScreen(),
                ),
              );
              break;
            case 2:
              // Navigate to settings screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              break;
            case 3:
              // Navigate to profile screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
