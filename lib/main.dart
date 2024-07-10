import 'package:flame/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/hud.dart';
import 'game/dino_run.dart';
import 'models/settings.dart';
import 'widgets/main_menu.dart';
import 'models/player_data.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';
import 'services/api_service.dart';

Future<void> main() async {
  // Ensures that all bindings are initialized
  // before we start calling hive and flame code
  // dealing with platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Create the ApiService instance
  final apiService = ApiService('https://yourapi.com');

  // Initializes hive and register the adapters.
  await initHive(apiService);

  runApp(DinoRunApp(apiService: apiService));
}

// This function will initialize hive with the app's documents directory.
// Additionally, it will also register all the hive adapters.
Future<void> initHive(ApiService apiService) async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter(apiService));
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

// The main widget for this game.
class DinoRunApp extends StatelessWidget {
  final ApiService apiService;

  const DinoRunApp({required this.apiService, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerData(apiService),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dino Run',
        theme: ThemeData(
          fontFamily: 'Audiowide',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Setting up some default theme for elevated buttons.
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              fixedSize: const Size(200, 60),
            ),
          ),
        ),
        home: Scaffold(
          body: GameWidget<DinoRun>.controlled(
            // This will display a loading bar until [DinoRun] completes
            // its onLoad method.
            loadingBuilder: (context) => const Center(
              child: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
            ),
            // Register all the overlays that will be used by this game.
            overlayBuilderMap: {
              MainMenu.id: (_, game) => MainMenu(game),
              PauseMenu.id: (_, game) => PauseMenu(game),
              Hud.id: (_, game) => Hud(game),
              GameOverMenu.id: (_, game) => GameOverMenu(game),
              SettingsMenu.id: (_, game) => SettingsMenu(game),
            },
            // By default MainMenu overlay will be active.
            initialActiveOverlays: const [MainMenu.id],
            gameFactory: () => DinoRun(
              // Use a fixed resolution camera to avoid manually
              // scaling and handling different screen sizes.
              camera: CameraComponent.withFixedResolution(
                width: 360,
                height: 180,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
