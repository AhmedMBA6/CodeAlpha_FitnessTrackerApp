import 'package:flutter/material.dart';
import '../../core/utils/haptic_feedback.dart';
import '../../core/l10n/app_localizations.dart';

class FeaturesSummary extends StatelessWidget {
  const FeaturesSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.appName} - New Features'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.speed,
            title: 'Performance & Reliability',
            description: '• Fixed map tile loading issues\n• Added loading states and error handling\n• Implemented retry logic for failed requests\n• Added error boundaries for graceful failure handling',
            color: Colors.blue,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.touch_app,
            title: 'Enhanced User Experience',
            description: '• Added haptic feedback for interactions\n• Implemented loading overlays\n• Added accessible buttons and widgets\n• Improved error messages and user guidance',
            color: Colors.green,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.share,
            title: 'Route Sharing & Export',
            description: '• Share routes via social media\n• Export data in JSON/CSV formats\n• Generate detailed fitness reports\n• Create shareable route URLs',
            color: Colors.orange,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.flag,
            title: 'Goal Templates',
            description: '• Pre-defined goal types (5K, 10K, Marathon)\n• Difficulty-based goal categories\n• Estimated completion times\n• Quick goal creation from templates',
            color: Colors.purple,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.emoji_events,
            title: 'Achievement System',
            description: '• Badges for milestones and accomplishments\n• Progress tracking for achievements\n• Achievement categories and types\n• Unlock notifications and celebrations',
            color: Colors.amber,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.analytics,
            title: 'Advanced Analytics',
            description: '• Pace analysis and segments\n• Elevation data and charts\n• Heart rate integration (framework)\n• Training load calculations\n• Performance metrics tracking',
            color: Colors.indigo,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.accessibility,
            title: 'Accessibility Improvements',
            description: '• Screen reader support\n• Semantic labels for all widgets\n• Keyboard navigation support\n• High contrast mode compatibility\n• Voice control integration',
            color: Colors.teal,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.language,
            title: 'Internationalization',
            description: '• Multi-language support (English, Spanish, French)\n• Localized strings and messages\n• Cultural adaptations\n• RTL language support framework',
            color: Colors.pink,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.code,
            title: 'Code Quality',
            description: '• Modular widget architecture\n• Reusable components\n• Error boundary implementation\n• Consistent coding patterns\n• Performance optimizations',
            color: Colors.grey,
          ),
          _buildFeatureCard(
            context,
            icon: Icons.rocket_launch,
            title: 'Future-Ready Features',
            description: '• HealthKit/Google Fit integration framework\n• Wearable device support preparation\n• Social features architecture\n• Monetization framework\n• Cloud sync preparation',
            color: Colors.red,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.buttonPress();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.check),
        label: Text(l10n.ok),
        heroTag: 'features_summary_fab',
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          HapticFeedback.buttonPress();
          _showFeatureDetails(context, title, description, color);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureDetails(BuildContext context, String title, String description, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(description),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.buttonPress();
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 