import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/firebase_options.dart';
import 'package:safezone_ultra/backend/content_seeder.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/screens/auth/splash_screen.dart';
import 'package:safezone_ultra/ui/screens/auth/login_screen.dart';
import 'package:safezone_ultra/ui/screens/auth/register_screen.dart';
import 'package:safezone_ultra/ui/screens/child/child_profile_select_screen.dart';
import 'package:safezone_ultra/ui/screens/child/child_shell.dart';
import 'package:safezone_ultra/ui/screens/lessons/lesson_list_screen.dart';
import 'package:safezone_ultra/ui/screens/lessons/lesson_player_screen.dart';
import 'package:safezone_ultra/ui/screens/quiz/quiz_screen.dart';
import 'package:safezone_ultra/ui/screens/quiz/quiz_result_screen.dart';
import 'package:safezone_ultra/ui/screens/parent/parent_shell.dart';
import 'package:safezone_ultra/ui/screens/parent/child_progress_detail_screen.dart';
import 'package:safezone_ultra/ui/screens/parent/screen_time_settings_screen.dart';
import 'package:safezone_ultra/ui/screens/parent/settings_screen.dart';
import 'package:safezone_ultra/ui/screens/parent/offline_content_screen.dart';
import 'package:safezone_ultra/ui/screens/games/mind_game_screen.dart';
import 'package:safezone_ultra/ui/screens/games/maze_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ContentSeeder().seedAndLoad();
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
          '/maze-game': (_) => const MazeGameScreen(),
        },
      ),
    );
  }
}
