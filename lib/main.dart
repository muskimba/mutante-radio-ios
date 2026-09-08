import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'home_page.dart';
import 'radio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.mutanteradio.mutante_radio.audio',
      androidNotificationChannelName: 'Reprodução',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (e) {
    debugPrint('JustAudioBackground.init falhou: $e');
  }
  await RadioService.instance.start();
  runApp(const MutanteRadioApp());
}

class MutanteRadioApp extends StatelessWidget {
  const MutanteRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mutante Radio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
