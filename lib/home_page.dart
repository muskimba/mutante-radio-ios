import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config.dart';
import 'now_playing_sheet.dart';
import 'player_bar.dart';
import 'radio_service.dart';

/// Ativado só via `--dart-define=DEMO_MODE=true` (build de CI pra gerar
/// vídeo/screenshot de divulgação) — toca e abre o player sozinho.
const _kDemoMode = bool.fromEnvironment('DEMO_MODE');

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _web;
  bool _loading = true;
  bool _error = false;
  bool _demoStarted = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _error = false;
          }),
          onPageFinished: (_) async {
            await _web.runJavaScript(Config.injectedJs);
            if (mounted) setState(() => _loading = false);
            if (_kDemoMode && !_demoStarted) {
              _demoStarted = true;
              _runDemoSequence();
            }
          },
          onWebResourceError: (err) {
            if (err.isForMainFrame ?? true) {
              setState(() {
                _error = true;
                _loading = false;
              });
            }
          },
          onNavigationRequest: (req) {
            final host = Uri.tryParse(req.url)?.host ?? '';
            final internal = Config.internalHosts.any((h) => host == h || host.endsWith('.$h'));
            if (internal) return NavigationDecision.navigate;
            launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(Config.siteUrl));
  }

  Future<void> _handleBack() async {
    if (await _web.canGoBack()) {
      await _web.goBack();
    } else if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _runDemoSequence() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    RadioService.instance.toggle();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    showNowPlayingSheet(context);
  }

  Future<void> _reload() async {
    setState(() {
      _error = false;
      _loading = true;
    });
    await _web.loadRequest(Uri.parse(Config.siteUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (!_error) WebViewWidget(controller: _web),
                    if (_error) _ErrorView(onRetry: _reload),
                    if (_loading && !_error)
                      const LinearProgressIndicator(minHeight: 2),
                  ],
                ),
              ),
              PlayerBar(
                onTap: () => showNowPlayingSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: Colors.white38),
            const SizedBox(height: 16),
            const Text(
              'Não deu pra carregar o site.\nVerifique a conexão.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'O rádio ainda toca pelo botão abaixo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
