import 'package:flutter/material.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert' show jsonDecode;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/local_storage_service.dart';

void main() async {
  // Global Flutter error handler to capture uncaught framework errors.
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrint(details.stack?.toString());
  };

  // Catch any uncaught async errors and ensure initialization happens inside
  // the same zone as runApp to avoid the 'Zone mismatch' warning.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('pl'), Locale('en'), Locale('de')],
        path: 'lib/core/localization/translation',
        fallbackLocale: const Locale('pl'),
        startLocale: const Locale('pl'),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught async error: $error');
    debugPrint(stack.toString());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _savedLocale;
  bool _loading = true;
  bool _didPrintLocale = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale_code');
    if (code != null) {
      setState(() {
        _savedLocale = Locale(code);
        _loading = false;
      });
      // ignore: use_build_context_synchronously
      context.setLocale(Locale(code));
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));

    // One-time debug dump to inspect loaded locale and translations.
    if (!_didPrintLocale) {
      _didPrintLocale = true;
      try {
        debugPrint('DEBUG: current locale=${context.locale}');
        debugPrint('DEBUG: supported locales=${context.supportedLocales}');
        debugPrint('DEBUG: tr(login.email)=' + 'login.email'.tr());
        debugPrint('DEBUG: tr(login.password)=' + 'login.password'.tr());
        debugPrint('DEBUG: tr(login.button)=' + 'login.button'.tr());
        debugPrint('DEBUG: tr(login.no_account)=' + 'login.no_account'.tr());
        debugPrint('DEBUG: tr(home.welcome)=' + 'home.welcome'.tr(namedArgs: {'user': 'DebugUser'}));
      } catch (e, s) {
        debugPrint('DEBUG: error while printing translations: $e');
        debugPrint(s.toString());
      }
      // Also attempt to load the JSON file directly from assets to inspect its content.
      // Use a post-frame callback to ensure the app stays alive long enough and
      // context is stable.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final lang = context.locale.languageCode;
          final path = 'lib/core/localization/translation/$lang.json';
          final raw = await rootBundle.loadString(path);
          try {
            final Map m = jsonDecode(raw) as Map;
            debugPrint('DEBUG: loaded translation file $path top keys: ${m.keys.toList()}');
            final login = m['login'];
            debugPrint('DEBUG: login key from file: ${login != null}');
            debugPrint('DEBUG: login.email raw=${login != null ? login['email'] : 'null'}');
          } catch (e, s) {
            debugPrint('DEBUG: error parsing $path: $e');
            debugPrint(s.toString());
          }
        } catch (e, s) {
          debugPrint('DEBUG: error loading translation asset: $e');
          debugPrint(s.toString());
        }
      });
    }
    return MaterialApp(
      title: 'Gra Miejska',
      theme: ThemeData.dark(),
      home: _savedLocale == null ? const SplashLanguageScreen() : const MyHomePage(title: 'Gra Miejska'),
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
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MyHomePage(title: 'Gra Miejska')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => _setLocale(context, 'pl'), child: const Text('POLSKI')),
            ElevatedButton(onPressed: () => _setLocale(context, 'en'), child: const Text('ENGLISH')),
            ElevatedButton(onPressed: () => _setLocale(context, 'de'), child: const Text('DEUTSCH')),
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showRegister = false;

  void _changeLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', code);
    await context.setLocale(Locale(code));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (code) => _changeLanguage(context, code),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'pl', child: Text('POLSKI')),
              PopupMenuItem(value: 'en', child: Text('ENGLISH')),
              PopupMenuItem(value: 'de', child: Text('DEUTSCH')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(child: _showRegister ? _buildRegisterForm(context) : _buildLoginForm(context)),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
  Text('home.welcome'.tr(namedArgs: {'user': _emailController.text.isNotEmpty ? _emailController.text : 'Użytkowniku'})),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: TextField(controller: _emailController, decoration: InputDecoration(labelText: 'login.email'.tr())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'login.password'.tr())),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () {}, child: Text('login.button'.tr())),
        TextButton(onPressed: () => setState(() => _showRegister = true), child: Text('login.no_account'.tr())),
      ],
    );
  }

  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('register.title'.tr()),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: TextField(controller: _registerEmailController, decoration: InputDecoration(labelText: 'login.email'.tr())),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: TextField(controller: _registerPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'login.password'.tr())),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final email = _registerEmailController.text.trim();
            final password = _registerPasswordController.text.trim();
            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('login.error'.tr())));
              return;
            }
            try {
              await LocalStorageService.saveUser(email, password);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('register.success'.tr())));
              setState(() {
                _showRegister = false;
                _emailController.text = email;
                _passwordController.text = '';
                _registerEmailController.clear();
                _registerPasswordController.clear();
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('login.error'.tr())));
            }
          },
          child: Text('register.button'.tr()),
        ),
        TextButton(onPressed: () => setState(() => _showRegister = false), child: Text('login.button'.tr())),
      ],
    );
  }
}

