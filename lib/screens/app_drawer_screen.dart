import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device_apps/device_apps.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AppDrawerScreen extends StatelessWidget {
  const AppDrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppTheme.graphite.withOpacity(0.95),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  "APPLICATIONS",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 16),
                Expanded(
                  child: appState.installedApps.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: appState.installedApps.length,
                          itemBuilder: (context, index) {
                            final app = appState.installedApps[index];
                            return _AppGridItem(app: app, index: index)
                                .animate()
                                .fade(duration: 300.ms, delay: Duration(milliseconds: 20 * index.clamp(0, 15)))
                                .scale(begin: const Offset(0.9, 0.9));
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
        // Optionally close the drawer when an app is launched:
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: app is ApplicationWithIcon
                  ? Image.memory(
                      (app as ApplicationWithIcon).icon,
                      fit: BoxFit.contain,
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(Icons.android, color: AppTheme.accentBlue),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.appName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
