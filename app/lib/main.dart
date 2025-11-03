import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/game_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_intro_screen.dart';
import 'screens/game_map_screen.dart';
import 'screens/faction_selection_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/choice_game_screen.dart';
import 'screens/text_challenge_screen.dart';
import 'screens/inventory_screen.dart';
import 'package:provider/provider.dart';
import 'providers/gps_provider_wrapper.dart';
import 'providers/game_progress_provider_wrapper.dart';
import 'providers/settings_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/register_screen.dart';
import 'screens/mission_runner_screen.dart';
// ...existing code...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('pl'), Locale('en'), Locale('de')],
      path: 'lib/core/localization/translation',
      fallbackLocale: const Locale('pl'),
      startLocale: const Locale('pl'),
      child: GpsProviderWrapper(
        child: GameProgressProviderWrapper(
          child: ChangeNotifierProvider(
            create: (_) => SettingsProvider(),
            child: const MyApp(),
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _savedLocale;
  bool _loading = true;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    // Splash przez ~5 sekund
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      _showSplash = false;
    });
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale_code');
    if (code != null) {
      setState(() {
        _savedLocale = Locale(code);
        _loading = false;
      });
      context.setLocale(Locale(code));
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a single MaterialApp instance for the whole lifetime of the app.
    // Switching between different MaterialApp instances can cause a
    // brief white frame on some devices. Instead pick the home widget
    // dynamically while keeping the same app/theme widgets.
    Widget homeWidget;
    if (_loading || _showSplash) {
      homeWidget = const SplashScreen();
    } else {
      homeWidget = _savedLocale == null
          ? const SplashLanguageScreen()
          : const MyHomePage(title: 'Flutter Demo Home Page');
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF181818),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
          bodySmall: TextStyle(fontFamily: 'Roboto'),
          titleLarge: TextStyle(fontFamily: 'Roboto'),
          titleMedium: TextStyle(fontFamily: 'Roboto'),
          titleSmall: TextStyle(fontFamily: 'Roboto'),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          surface: const Color(0xFF181818),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>((
              states,
            ) {
              if (states.contains(MaterialState.pressed))
                return Colors.deepPurple;
              return Colors.grey; // default
            }),
            foregroundColor: MaterialStateProperty.resolveWith<Color?>((
              states,
            ) {
              // Keep text readable on both backgrounds
              return Colors.white;
            }),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                inherit: false,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color?>((
              states,
            ) {
              if (states.contains(MaterialState.pressed))
                return Colors.deepPurple;
              return Colors.grey;
            }),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF232323),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          labelStyle: TextStyle(color: Colors.white70, fontFamily: 'Roboto'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232323),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: homeWidget,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/games': (context) => const GameListScreen(),
        '/intro': (context) => const GameIntroScreen(),
        '/faction': (context) => const FactionSelectionScreen(),
        '/map': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final faction = args != null ? args['faction'] as String? : null;
          return GameMapScreen(returnRoute: '/intro', faction: faction);
        },
        '/choice': (context) => const ChoiceGameScreen(),
        '/text_challenge': (context) => const TextChallengeScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/mission': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final id = args != null ? args['id'] as String? : null;
          return MissionRunnerScreen(missionId: id ?? 'a1');
        },
        '/home': (context) {
          // Pobierz ostatniego użytkownika z SharedPreferences
          final prefs = SharedPreferences.getInstance();
          // Uwaga: to jest Future, więc musimy użyć FutureBuilder
          return FutureBuilder<SharedPreferences>(
            future: prefs,
            builder: (context, snapshot) {
              // HomeScreen now loads user internally
              return const HomeScreen();
            },
          );
        },
        // Add more routes as needed
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class SplashLanguageScreen extends StatelessWidget {
  const SplashLanguageScreen({super.key});

  Future<void> _setLocale(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', code);
    await context.setLocale(Locale(code));
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _setLocale(context, 'pl'),
              child: const Text('POLSKI'),
            ),
            ElevatedButton(
              onPressed: () => _setLocale(context, 'en'),
              child: const Text('ENGLISH'),
            ),
            ElevatedButton(
              onPressed: () => _setLocale(context, 'de'),
              child: const Text('DEUTSCH'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadLastUser();
  }

  Future<void> _loadLastUser() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUser = prefs.getString('last_user');
    if (lastUser != null && lastUser.isNotEmpty) {
      _emailController.text = lastUser;
    }
  }

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _repeatFocus = FocusNode();
  bool _isLogin = true;
  String? _errorMessage;
  String? _successMessage;
  bool _loading = false;

  // void _incrementCounter() {}

  void _changeLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', code);
    await context.setLocale(Locale(code));
    setState(() {});
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _successMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _repeatPasswordController.clear();
    });
    FocusScope.of(context).requestFocus(_loginFocus);
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _loading = true;
    });
    final login = _emailController.text.trim();
    final password = _passwordController.text;
    final repeatPassword = _repeatPasswordController.text;
    if (login.isEmpty || login.length < 3) {
      setState(() {
        _errorMessage = 'Podaj login (min. 3 znaki)';
        _loading = false;
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Hasło musi mieć min. 6 znaków';
        _loading = false;
      });
      return;
    }
    if (!_isLogin && password != repeatPassword) {
      setState(() {
        _errorMessage = 'Hasła nie są takie same';
        _loading = false;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    // Zapamiętaj ostatniego użytkownika
    await prefs.setString('last_user', login);
    final users = prefs.getStringList('users') ?? [];
    // Format: login:password (plain, demo only; w produkcji - hash!)
    if (_isLogin) {
      final found = users.any((u) {
        final parts = u.split(':');
        return parts.length == 2 && parts[0] == login && parts[1] == password;
      });
      setState(() {
        _loading = false;
        if (found) {
          _successMessage = 'Zalogowano pomyślnie!';
        } else {
          _errorMessage = 'Nieprawidłowy login lub hasło';
        }
      });
      if (found) {
        // Navigate to HomeScreen after successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      final exists = users.any((u) => u.split(':').first == login);
      if (exists) {
        setState(() {
          _errorMessage = 'Użytkownik o tym loginie już istnieje';
          _loading = false;
        });
        return;
      }
      users.add('$login:$password');
      await prefs.setStringList('users', users);
      setState(() {
        _successMessage =
            'Rejestracja zakończona sukcesem! Możesz się zalogować.';
        _isLogin = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isLogin ? 'Logowanie' : 'Rejestracja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ustawienia',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (code) => _changeLanguage(context, code),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'pl', child: const Text('POLSKI')),
              PopupMenuItem(value: 'en', child: const Text('ENGLISH')),
              PopupMenuItem(value: 'de', child: const Text('DEUTSCH')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isLogin ? 'Witaj ponownie!' : 'Załóż nowe konto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _emailController,
                  focusNode: _loginFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocus),
                  decoration: const InputDecoration(labelText: 'Login'),
                  autofillHints: const [AutofillHints.username],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: true,
                  textInputAction: _isLogin
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    if (_isLogin) {
                      _submit();
                    } else {
                      FocusScope.of(context).requestFocus(_repeatFocus);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Hasło'),
                  autofillHints: const [AutofillHints.password],
                ),
              ),
              if (!_isLogin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextField(
                    controller: _repeatPasswordController,
                    focusNode: _repeatFocus,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Powtórz hasło',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              const SizedBox(height: 8),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        _isLogin
                            ? 'login.button'.tr().toUpperCase()
                            : 'register.button'.tr().toUpperCase(),
                      ),
                    ),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin
                      ? 'login.no_account'.tr().toUpperCase()
                      : 'MASZ JUŻ KONTO? ZALOGUJ SIĘ',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SplashScreen widget (top-level)

// ...existing code...
