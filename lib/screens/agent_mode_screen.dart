import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AgentModeScreen extends StatefulWidget {
  const AgentModeScreen({super.key});

  @override
  State<AgentModeScreen> createState() => _AgentModeScreenState();
}

class _AgentModeScreenState extends State<AgentModeScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppTheme.graphite,
          body: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: AppTheme.getBackgroundGradient(appState.currentMode),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 40),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AGENT PROTOCOL",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "MISSION CONTROL",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ).animate().fade(duration: 500.ms).slideX(begin: -0.2),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                            onPressed: () => Navigator.pop(context),
                          ).animate().fade(duration: 500.ms).slideX(begin: 0.2),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Focus Timer
                      _buildSectionTitle(context, "FOCUS PROTOCOL").animate().fade(duration: 500.ms, delay: 100.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        child: Column(
                          children: [
                            Text(
                              appState.isFocusTimerRunning
                                  ? _formatDuration(appState.focusTimeRemaining)
                                  : "00:00",
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: appState.isFocusTimerRunning ? AppTheme.accentBlue : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildButton(
                                  context,
                                  appState.isFocusTimerRunning ? "ABORT" : "INITIATE (25m)",
                                  onPressed: () {
                                    if (appState.isFocusTimerRunning) {
                                      appState.stopFocusTimer();
                                    } else {
                                      appState.startFocusTimer(25);
                                    }
                                  },
                                  isDestructive: appState.isFocusTimerRunning,
                                ),
                              ],
                            )
                          ],
                        ),
                      ).animate().fade(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 32),
                      // Missions
                      _buildSectionTitle(context, "ACTIVE MISSIONS").animate().fade(duration: 500.ms, delay: 300.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appState.tasks.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                          itemBuilder: (context, index) {
                            final task = appState.tasks[index];
                            return Dismissible(
                              key: Key(task),
                              onDismissed: (_) => appState.removeTask(index),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: AppTheme.accentBlue.withOpacity(0.2),
                                child: const Icon(Icons.check, color: AppTheme.accentBlue),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.radio_button_unchecked, color: AppTheme.textSecondary),
                                title: Text(task, style: Theme.of(context).textTheme.bodyLarge),
                                trailing: const Icon(Icons.drag_handle, color: AppTheme.textSecondary, size: 16),
                              ),
                            );
                          },
                        ),
                      ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),
                      // AI Configuration
                      _buildSectionTitle(context, "AI INTEGRATION").animate().fade(duration: 500.ms, delay: 500.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.aiService.isInitialized ? "SYSTEM ONLINE" : "AWAITING AUTHORIZATION",
                              style: TextStyle(
                                color: appState.aiService.isInitialized ? Colors.greenAccent : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _apiKeyController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Enter Gemini API Key",
                                hintStyle: Theme.of(context).textTheme.bodyMedium,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.accentBlue),
                                ),
                                filled: true,
                                fillColor: Colors.black12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildButton(
                                context,
                                "AUTHORIZE",
                                onPressed: () {
                                  if (_apiKeyController.text.isNotEmpty) {
                                    appState.setApiKey(_apiKeyController.text);
                                    _apiKeyController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('AI Key Authorized')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 600.ms, delay: 600.ms).slideY(begin: 0.1),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondary,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, {required VoidCallback onPressed, bool isDestructive = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.redAccent.withOpacity(0.2) : AppTheme.accentBlue.withOpacity(0.2),
        foregroundColor: isDestructive ? Colors.redAccent : AppTheme.accentBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(color: isDestructive ? Colors.redAccent.withOpacity(0.5) : AppTheme.accentBlue.withOpacity(0.5)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  String _formatDuration(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
