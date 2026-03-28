import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_apps/device_apps.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AppDrawerScreen extends StatelessWidget {
  const AppDrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: Colors.transparent, // Allow Home background to peek through if blurred
          body: Stack(
            children: [
              // Frosted background for iOS feel
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      "APP LIBRARY",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fade(duration: 400.ms).slideY(begin: -0.1),
                    const SizedBox(height: 16),
                    Expanded(
                      child: appState.installedApps.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                          : GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 36,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: appState.installedApps.length,
                              itemBuilder: (context, index) {
                                final app = appState.installedApps[index];
                                return _AppGridItem(app: app, index: index)
                                    .animate()
                                    .fade(duration: 300.ms, delay: Duration(milliseconds: 15 * index.clamp(0, 20)))
                                    .scale(begin: const Offset(0.9, 0.9));
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

class _AppGridItem extends StatelessWidget {
  final Application app;
  final int index;

  const _AppGridItem({required this.app, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<AppState>(context, listen: false).launchApp(app.packageName);
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: app is ApplicationWithIcon
                    ? Image.memory(
                        (app as ApplicationWithIcon).icon,
                        fit: BoxFit.cover,
                      )
                    : const Container(
                        color: Colors.white12,
                        child: Icon(Icons.android, color: Colors.white54),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            app.appName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
