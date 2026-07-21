import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/app_state.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/child_profile_select_screen.dart';
import 'ui/screens/child_shell.dart';
import 'ui/screens/lesson_list_screen.dart';
import 'ui/screens/lesson_player_screen.dart';
import 'ui/screens/quiz_screen.dart';
import 'ui/screens/quiz_result_screen.dart';
import 'ui/screens/parent_shell.dart';
import 'ui/screens/child_progress_detail_screen.dart';
import 'ui/screens/screen_time_settings_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/offline_content_screen.dart';
import 'ui/screens/mind_game_screen.dart';

void main() {
  runApp(const SafeZoneUltraApp());
}

class SafeZoneUltraApp extends StatelessWidget {
  const SafeZoneUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'SafeZone Ultra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/profiles': (_) => const ChildProfileSelectScreen(),
          '/child': (_) => const ChildShell(),
          '/lessons': (_) => const LessonListScreen(),
          '/lesson-player': (_) => const LessonPlayerScreen(),
          '/quiz': (_) => const QuizScreen(),
          '/quiz-result': (_) => const QuizResultScreen(),
          '/parent': (_) => const ParentShell(),
          '/child-progress': (_) => const ChildProgressDetailScreen(),
          '/screen-time': (_) => const ScreenTimeSettingsScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/offline': (_) => const OfflineContentScreen(),
          '/mind-game': (_) => const MindGameScreen(),
        },
      ),
    );
  }
}
