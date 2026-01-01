import 'package:flutter/material.dart';
import '../models/audio_item.dart';
import 'recording_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'audio_player_screen.dart';

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
  
  // Search query
  String _searchQuery = '';
  
  // Sample audio items (will be replaced with real data from backend)
  List<AudioItem> _allAudios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.fetchAudios();
      setState(() {
        _allAudios = data.map((json) => AudioItem.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audios: $e')),
        );
      }
    }
  }

  /// Get filtered audio items based on selected filter and search query
  List<AudioItem> get _filteredAudios {
    return _allAudios.where((audio) {
      final matchesSearch = audio.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || audio.type.toLowerCase() == _selectedFilter.toLowerCase();
      return matchesSearch && matchesFilter;
    }).toList();
  }

  /// Handle filter selection
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  /// Handle play button press -> Navigate to Detailed Player
  void _handlePlay(AudioItem audio) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AudioPlayerScreen(audio: audio),
      ),
    );
  }

  /// Handle share button press
  void _handleShare(AudioItem audio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: ${audio.title}')),
    );
  }

  /// Handle delete button press
  void _handleDelete(AudioItem audio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleting: ${audio.title}')),
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
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic, size: 32, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Voice Recorder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (Figma PDF 5)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search recordings...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Filter options (Chips style like Figma)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Original', 'original'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cleaned', 'cleaned'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Audio list
            Expanded(
              child: _filteredAudios.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredAudios.length,
                      itemBuilder: (context, index) {
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
                  const Text(
                    'Your voice. Crystal clear.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleStartRecording,
                    icon: const Icon(Icons.mic, size: 24),
                    label: const Text('Start Recording'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) _selectFilter(filter);
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No recordings found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAudioItem(AudioItem audio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              onPressed: () => _handleShare(audio),
            ),
            IconButton(
              icon: Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary, size: 32),
              onPressed: () => _handlePlay(audio),
            ),
          ],
        ),
        onTap: () => _handlePlay(audio),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) return;
        Widget nextScreen;
        switch (index) {
          case 1: nextScreen = const RecordingScreen(); break;
          case 2: nextScreen = const SettingsScreen(); break;
          case 3: nextScreen = const ProfileScreen(); break;
          default: return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => nextScreen));
      },
    );
  }
}

