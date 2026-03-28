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
                curve: Curves.easeOutCubic,
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
                      const SizedBox(height: 20),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SYSTEM: ONLINE",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.accentBlue,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "AGENT CONTROL",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ).animate().fade(duration: 500.ms).slideX(begin: -0.1),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ).animate().fade(duration: 500.ms).slideX(begin: 0.1),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Focus Timer
                      _buildSectionTitle(context, "FOCUS PROTOCOL").animate().fade(duration: 500.ms, delay: 100.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(32),
                        borderRadius: 32,
                        opacity: 0.1,
                        child: Column(
                          children: [
                            Text(
                              appState.isFocusTimerRunning
                                  ? _formatDuration(appState.focusTimeRemaining)
                                  : "25:00",
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: appState.isFocusTimerRunning ? AppTheme.accentBlue : AppTheme.textPrimary,
                                fontSize: 64,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: _buildButton(
                                context,
                                appState.isFocusTimerRunning ? "ABORT PROTOCOL" : "INITIATE DEEP WORK",
                                onPressed: () {
                                  if (appState.isFocusTimerRunning) {
                                    appState.stopFocusTimer();
                                  } else {
                                    appState.startFocusTimer(25);
                                  }
                                },
                                isDestructive: appState.isFocusTimerRunning,
                              ),
                            )
                          ],
                        ),
                      ).animate().fade(duration: 600.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 32),
                      // Missions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle(context, "ACTIVE MISSIONS"),
                          if (appState.aiService.isInitialized)
                            GestureDetector(
                              onTap: appState.isGeneratingTasks ? null : () => appState.generateAITasks(),
                              child: appState.isGeneratingTasks
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentBlue))
                                : Text("AI SYNC", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ).animate().fade(duration: 500.ms, delay: 300.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 24,
                        opacity: 0.1,
                        child: appState.tasks.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(child: Text("All objectives complete.", style: Theme.of(context).textTheme.bodyMedium)),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: appState.tasks.length,
                                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                                itemBuilder: (context, index) {
                                  final task = appState.tasks[index];
                                  return Dismissible(
                                    key: UniqueKey(),
                                    onDismissed: (_) => appState.removeTask(index),
                                    direction: DismissDirection.startToEnd,
                                    background: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      child: const Icon(Icons.check, color: AppTheme.accentBlue),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: const Icon(Icons.circle_outlined, color: AppTheme.textSecondary, size: 20),
                                      title: Text(task, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                                    ),
                                  );
                                },
                              ),
                      ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),
                      // AI Configuration
                      _buildSectionTitle(context, "NEURAL LINK (GEMINI AI)").animate().fade(duration: 500.ms, delay: 500.ms),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        borderRadius: 24,
                        opacity: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appState.aiService.isInitialized ? Colors.greenAccent : Colors.redAccent,
                                    boxShadow: [
                                      BoxShadow(color: (appState.aiService.isInitialized ? Colors.greenAccent : Colors.redAccent).withOpacity(0.5), blurRadius: 8)
                                    ]
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  appState.aiService.isInitialized ? "AI AUTHORIZED" : "AWAITING KEY",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _apiKeyController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Enter Gemini API Key...",
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white24),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppTheme.accentBlue),
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.3),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: _buildButton(
                                context,
                                "AUTHORIZE UPLINK",
                                onPressed: () {
                                  if (_apiKeyController.text.isNotEmpty) {
                                    appState.setApiKey(_apiKeyController.text);
                                    _apiKeyController.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Uplink Authorized')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 600.ms, delay: 600.ms).slideY(begin: 0.05),
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
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, {required VoidCallback onPressed, bool isDestructive = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.redAccent.withOpacity(0.15) : AppTheme.accentBlue.withOpacity(0.15),
        foregroundColor: isDestructive ? Colors.redAccent : AppTheme.accentBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        side: BorderSide(color: isDestructive ? Colors.redAccent.withOpacity(0.3) : AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  String _formatDuration(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
