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
        transitionDuration: const Duration(milliseconds: 300), // Slightly faster
        reverseTransitionDuration: const Duration(milliseconds: 300),
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
          backgroundColor: Colors.black, // Fallback
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
                      child: FadeTransition(opacity: animation, child: child), // Blend fade & slide
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
                    scale: Tween<double>(begin: 1.1, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                }
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800), // Smoother state change
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: AppTheme.getBackgroundGradient(appState.currentMode),
              ),
              child: Stack(
                children: [
                  // Subtle noise overlay for texture
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
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
                        const SizedBox(height: 72),
                        // Clock (iOS style lock screen layout)
                        Center(
                          child: StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              return Text(
                                DateFormat('HH:mm').format(DateTime.now()),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  shadows: [
                                    Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))
                                  ]
                                ),
                              );
                            },
                          ),
                        ).animate().fade(duration: 800.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                        const SizedBox(height: 4),
                        // Date
                        Center(
                          child: StreamBuilder(
                            stream: Stream.periodic(const Duration(minutes: 1)),
                            builder: (context, snapshot) {
                              return Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.textPrimary.withOpacity(0.9),
                                  shadows: [
                                    Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                                  ]
                                ),
                              );
                            },
                          ),
                        ).animate().fade(duration: 800.ms, delay: 100.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                        const Spacer(),

                        // Floating iOS/VisionOS style Dock
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: GlassContainer(
                            height: 94,
                            borderRadius: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            opacity: 0.2, // Slightly more opaque to ground the dock
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _buildDockItems(appState, context),
                            ),
                          ),
                        ).animate().fade(duration: 800.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
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
    final maxApps = 4;
    int count = 0;

    // Attempt to prioritize certain standard apps if available (like Phone, Messages), but for now, just pick first few.
    for (var app in appState.installedApps) {
      if (count >= maxApps) break;
      if (app.packageName == 'com.example.horizon_launcher') continue;

      items.add(
        GestureDetector(
          onTap: () => appState.launchApp(app.packageName),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))
              ]
            ),
            child: app is ApplicationWithIcon
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16), // Slight roundness instead of full circle for a modern look
                  child: Image.memory(app.icon, fit: BoxFit.contain)
                )
              : const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.android, color: Colors.white)),
          ),
        )
      );
      count++;
    }

    // App Drawer Button - styled specifically
    items.add(
      GestureDetector(
        onTap: () {
          _navigateTo(
            context,
            const AppDrawerScreen(),
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: animation, child: child),
              );
            }
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Premium blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
            ]
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
        ),
      )
    );

    return items;
  }
}
