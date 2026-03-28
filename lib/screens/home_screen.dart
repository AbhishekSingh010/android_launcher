import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'agent_mode_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe down for Universal Search
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              }
            },
            onLongPress: () {
              // Long press to enter hidden Agent Mode
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AgentModeScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 1.2, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
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
                        // Dock / Core Apps (Minimal representation)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                          child: GlassContainer(
                            height: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            borderRadius: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildDockIcon(Icons.phone_outlined),
                                _buildDockIcon(Icons.chat_bubble_outline),
                                _buildDockIcon(Icons.camera_alt_outlined),
                                _buildDockIcon(Icons.language),
                              ],
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

  Widget _buildDockIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 28);
  }
}
