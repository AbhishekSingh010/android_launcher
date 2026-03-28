import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_apps/device_apps.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'agent_mode_screen.dart';
import 'search_screen.dart';
import 'app_drawer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTransitioning = false;

  void _navigateTo(BuildContext context, Widget screen, RouteTransitionsBuilder transitionsBuilder) {
    if (_isTransitioning) return;
    setState(() => _isTransitioning = true);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: transitionsBuilder,
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      if (mounted) setState(() => _isTransitioning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe down for Universal Search
                _navigateTo(
                  context,
                  const SearchScreen(),
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  }
                );
              } else if (details.primaryVelocity! < 0) {
                // Swipe up for App Drawer
                 _navigateTo(
                  context,
                  const AppDrawerScreen(),
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    );
                  }
                );
              }
            },
            onLongPress: () {
              // Long press to enter hidden Agent Mode
              _navigateTo(
                context,
                const AgentModeScreen(),
                (context, animation, secondaryAnimation, child) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 1.2, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                }
              );
            },
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(appState.currentMode),
              ),
              child: Stack(
                children: [
                  // Subtle noise overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.03,
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/d/d4/Texture_of_white_noise.png',
                        repeat: ImageRepeat.repeat,
                        fit: BoxFit.none,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        // Clock
                        Center(
                          child: StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              return Text(
                                DateFormat('HH:mm').format(DateTime.now()),
                                style: Theme.of(context).textTheme.displayLarge,
                              );
                            },
                          ),
                        ).animate().fade(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 10),
                        // Date
                        Center(
                          child: StreamBuilder(
                            stream: Stream.periodic(const Duration(minutes: 1)),
                            builder: (context, snapshot) {
                              return Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 2),
                              );
                            },
                          ),
                        ).animate().fade(duration: 800.ms, delay: 200.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                        const Spacer(),
                        // Dynamic Dock
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                          child: GlassContainer(
                            height: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            borderRadius: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _buildDockItems(appState, context),
                            ),
                          ),
                        ).animate().fade(duration: 800.ms, delay: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDockItems(AppState appState, BuildContext context) {
    List<Widget> items = [];

    // Show up to 4 real apps in the dock
    final maxApps = 4;
    int count = 0;

    for (var app in appState.installedApps) {
      if (count >= maxApps) break;
      // Skip the launcher itself
      if (app.packageName == 'com.example.horizon_launcher') continue;

      items.add(
        GestureDetector(
          onTap: () => appState.launchApp(app.packageName),
          child: SizedBox(
            width: 48,
            height: 48,
            child: app is ApplicationWithIcon
              ? Image.memory(app.icon, fit: BoxFit.contain)
              : const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.android, color: Colors.white)),
          ),
        )
      );
      count++;
    }

    // App Drawer Button
    items.add(
      GestureDetector(
        onTap: () {
          _navigateTo(
            context,
            const AppDrawerScreen(),
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            }
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentBlue.withOpacity(0.2),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.5)),
          ),
          child: const Icon(Icons.apps, color: AppTheme.accentBlue),
        ),
      )
    );

    return items;
  }
}
