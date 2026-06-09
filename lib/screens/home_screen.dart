import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/app_provider.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../widgets/action_toggle_card.dart';
import 'api_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadAd();
  }

  Future<void> _requestPermissions() async {
    await NotificationService.requestPermissions();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final enabledCount = provider.enabledActions.length;
    final totalCount = provider.actions.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('AI Text')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: provider.isApiConfigured
                                ? colorScheme.primaryContainer
                                : colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            provider.isApiConfigured
                                ? Icons.check_circle
                                : Icons.warning_rounded,
                            color: provider.isApiConfigured
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.isApiConfigured
                                    ? 'API Connected'
                                    : 'API Not Configured',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.isApiConfigured
                                    ? 'Model: ${provider.model}'
                                    : 'Tap to configure your Gemini API key',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApiSettingsScreen(),
                            ),
                          ),
                          child: Text(
                            provider.isApiConfigured ? 'Edit' : 'Setup',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'Active',
                          value: '$enabledCount',
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        _SummaryChip(
                          label: 'Total',
                          value: '$totalCount',
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 16),
                        _SummaryChip(
                          label: 'History',
                          value: '${provider.history.length}',
                          color: colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Quick Toggles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),

                ...provider.actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActionToggleCard(action: action),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isAdLoaded && _bannerAd != null
          ? SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
