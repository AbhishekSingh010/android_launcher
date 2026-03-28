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
          backgroundColor: AppTheme.graphite.withOpacity(0.95),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GlassContainer(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: 30,
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textSecondary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: "Search apps, files, or missions...",
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
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
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = "";
                              });
                            },
                          )
                      ],
                    ),
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 16),
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredApps.length,
                          itemBuilder: (context, index) {
                            final app = filteredApps[index];
                            return ListTile(
                              leading: app is ApplicationWithIcon
                                  ? Image.memory(app.icon, width: 40, height: 40)
                                  : const Icon(Icons.android, color: AppTheme.accentBlue),
                              title: Text(app.appName, style: Theme.of(context).textTheme.bodyLarge),
                              onTap: () {
                                appState.launchApp(app.packageName);
                                Navigator.pop(context);
                              },
                            ).animate().fade(duration: 300.ms, delay: Duration(milliseconds: 50 * index.clamp(0, 10))).slideX(begin: 0.1);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.explore_outlined, size: 64, color: Colors.white12),
        const SizedBox(height: 16),
        Text(
          "Awaiting Input",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white24,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fade(duration: 600.ms, delay: 200.ms);
  }
}
