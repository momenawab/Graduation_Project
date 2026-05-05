import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

class PowerBiReportScreen extends StatefulWidget {
  const PowerBiReportScreen({super.key});

  // ── PASTE YOUR URLs HERE ─────────────────────────────────────────────────
  /// overview_project.pbix — Embed for organization (requires Microsoft login in WebView)
  static const String historicalUrl =
      'https://app.powerbi.com/reportEmbed?reportId=548abf03-eef1-4a1f-bbe7-90be54683e88&autoAuth=true&ctid=def512e0-feee-407d-be2f-f68c954e75b7';

  /// Your new Streaming Dataset report → File → Embed report → Publish to web
  static const String liveUrl =
      'https://app.powerbi.com/view?r=REPLACE_WITH_LIVE_EMBED_URL';
  // ─────────────────────────────────────────────────────────────────────────

  @override
  State<PowerBiReportScreen> createState() => _PowerBiReportScreenState();
}

class _PowerBiReportScreenState extends State<PowerBiReportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final WebViewController _historicalController;
  late final WebViewController _liveController;

  bool _historicalLoading = true;
  bool _liveLoading = true;
  String? _historicalError;
  String? _liveError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _historicalController = _buildController(
      PowerBiReportScreen.historicalUrl,
      onLoading: (v) => setState(() => _historicalLoading = v),
      onError: (e) => setState(() {
        _historicalError = e;
        _historicalLoading = false;
      }),
    );

    _liveController = _buildController(
      PowerBiReportScreen.liveUrl,
      onLoading: (v) => setState(() => _liveLoading = v),
      onError: (e) => setState(() {
        _liveError = e;
        _liveLoading = false;
      }),
    );
  }

  WebViewController _buildController(
    String url, {
    required void Function(bool) onLoading,
    required void Function(String) onError,
  }) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => onLoading(true),
        onPageFinished: (_) => onLoading(false),
        onWebResourceError: (e) => onError(e.description),
      ))
      ..loadRequest(Uri.parse(url));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  WebViewController get _activeController =>
      _tabController.index == 0 ? _historicalController : _liveController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 20),
          ),
        ),
        title: Text(
          'Analytics Dashboard',
          style: styles.AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => _activeController.reload(),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.history, size: 18),
              text: 'Historical',
            ),
            Tab(
              icon: Icon(Icons.sensors, size: 18),
              text: 'Live',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWebView(
            controller: _historicalController,
            isLoading: _historicalLoading,
            error: _historicalError,
            onRetry: () {
              setState(() => _historicalError = null);
              _historicalController.reload();
            },
          ),
          _buildWebView(
            controller: _liveController,
            isLoading: _liveLoading,
            error: _liveError,
            onRetry: () {
              setState(() => _liveError = null);
              _liveController.reload();
            },
            isLive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWebView({
    required WebViewController controller,
    required bool isLoading,
    required String? error,
    required VoidCallback onRetry,
    bool isLive = false,
  }) {
    return Stack(
      children: [
        if (error != null)
          _buildError(error, onRetry, isLive: isLive)
        else
          WebViewWidget(controller: controller),

        if (isLoading && error == null)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: isLive ? Colors.greenAccent : AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  isLive ? 'Connecting to live feed…' : 'Loading report…',
                  style:
                      const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

        // Live indicator badge
        if (isLive && !isLoading && error == null)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(),
                  SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError(String error, VoidCallback onRetry,
      {bool isLive = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLive ? Icons.sensors_off : Icons.bar_chart_outlined,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isLive ? 'Live feed unavailable' : 'Could not load report',
              style: styles.AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isLive
                  ? 'Make sure the streaming dataset URL is configured and the backend is running.'
                  : error,
              textAlign: TextAlign.center,
              style: styles.AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLive ? Colors.green : AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small animated pulsing green dot for the LIVE badge.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.3, end: 1.0).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
