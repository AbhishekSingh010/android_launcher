import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_apps/device_apps.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final filteredApps = appState.installedApps
            .where((app) => app.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent, // Important for the frosted overlay
          body: Stack(
            children: [
              // Spotlight style frosted background
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Hero(
                        tag: 'search_bar',
                        child: Material(
                          color: Colors.transparent,
                          child: GlassContainer(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            borderRadius: 32,
                            opacity: 0.25,
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white70, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                                    decoration: InputDecoration(
                                      hintText: "Search apps...",
                                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white38, fontSize: 18),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = "";
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white24,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fade(duration: 300.ms).slideY(begin: -0.1),
                    const SizedBox(height: 24),
                    Expanded(
                      child: _searchQuery.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredApps.length,
                              itemBuilder: (context, index) {
                                final app = filteredApps[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GlassContainer(
                                    height: 72,
                                    borderRadius: 20,
                                    opacity: 0.1,
                                    showShadow: false,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: app is ApplicationWithIcon
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.memory(app.icon, width: 44, height: 44)
                                            )
                                          : const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.android, color: Colors.white)),
                                      title: Text(
                                        app.appName,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)
                                      ),
                                      onTap: () {
                                        appState.launchApp(app.packageName);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ).animate().fade(duration: 200.ms, delay: Duration(milliseconds: 30 * index.clamp(0, 10))).slideX(begin: 0.05);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
