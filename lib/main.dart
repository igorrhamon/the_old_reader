import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/old_reader_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pages/favorites_page.dart';
import 'pages/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Old Reader Client',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF6750A4),
          onPrimary: const Color(0xFFFFFFFF),
          primaryContainer: const Color(0xFFEADDFF),
          onPrimaryContainer: const Color(0xFF21005D),
          secondary: const Color(0xFF625B71),
          onSecondary: const Color(0xFFFFFFFF),
          secondaryContainer: const Color(0xFFE8DEF8),
          onSecondaryContainer: const Color(0xFF1D192B),
          surface: const Color(0xFFFFFBFE),
          onSurface: const Color(0xFF1C1B1F),
          error: const Color(0xFFB3261E),
          onError: const Color(0xFFFFFFFF),
          errorContainer: const Color(0xFFF9DEDC),
          onErrorContainer: const Color(0xFF410E0B),
          surfaceContainerHighest: const Color(0xFFE7E0EC),
          onSurfaceVariant: const Color(0xFF49454F),
          outline: const Color(0xFF79747E),
          outlineVariant: const Color(0xFFCAC4D0),
          shadow: const Color(0xFF000000),
          inverseSurface: const Color(0xFF313033),
          onInverseSurface: const Color(0xFFF4EFF4),
          inversePrimary: const Color(0xFFD0BCFF),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 57, letterSpacing: -0.25),
          displayMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 45),
          displaySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 36),
          headlineLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 32),
          headlineMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 28),
          headlineSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 24),
          titleLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 22),
          titleMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 16),
          titleSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 14),
          bodySmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.normal, fontSize: 12),
          labelLarge: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 14),
          labelMedium: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12),
          labelSmall: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 11),
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  OldReaderApi? _api;

  void _onLogin(OldReaderApi api) {
    setState(() {
      _api = api;
      _selectedIndex = 0;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = _api != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('The Old Reader', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        centerTitle: true,
        actions: [
          if (isLogged)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              color: Theme.of(context).colorScheme.onPrimary,
              onPressed: () => setState(() => _api = null),
            ),
        ],
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      drawer: isLogged
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('The Old Reader', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.rss_feed),
                    title: const Text('Feeds'),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('Favoritos'),
                    selected: _selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Configurações'),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onTabTapped(2);
                    },
                  ),
                ],
              ),
            )
          : null,
      body: isLogged
          ? Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: [
                    HomePage(api: _api!),
                    FavoritesPage(api: _api!),
                    const Center(child: Text('Configurações (em breve)', style: TextStyle(fontSize: 18))),
                  ],
                ),
                if (_selectedIndex == 0)
                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () {
                        // TODO: ação de adicionar feed
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionar feed (em breve)')));
                      },
                      tooltip: 'Adicionar feed',
                      child: const Icon(Icons.add),
                    ),
                  ),
              ],
            )
          : LoginPage(onLogin: _onLogin),
      bottomNavigationBar: isLogged
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTabTapped,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.rss_feed), label: 'Feeds'),
                NavigationDestination(icon: Icon(Icons.bookmark), label: 'Favoritos'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'Configurações'),
              ],
            )
          : null,
    );
  }
}

class LoginPage extends StatefulWidget {
  final void Function(OldReaderApi api)? onLogin;
  const LoginPage({super.key, this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Informe o e-mail e a senha.';
        _loading = false;
      });
      return;
    }

    try {
      final url = Uri.parse('http://localhost:3000/proxy/accounts/ClientLogin');
      final body = 'client=theoldreader_flutter_app&accountType=HOSTED_OR_GOOGLE&service=reader&Email=${Uri.encodeComponent(email)}&Passwd=${Uri.encodeComponent(password)}&output=json';
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = response.body;
        String? token;
        // Tenta extrair o token do JSON ou do texto
        try {
          final json = data.startsWith('{') ? jsonDecode(data) : null;
          if (json != null && json['Auth'] != null) {
            token = json['Auth'];
          }
        } catch (_) {
          // fallback para texto plano
          final match = RegExp(r'Auth=(.+)').firstMatch(data);
          if (match != null) token = match.group(1);
        }
        if (token != null && token.isNotEmpty) {
          final api = OldReaderApi(token);
          final userInfo = await api.getUserInfo();
          if (userInfo.statusCode == 200) {
            if (widget.onLogin != null) widget.onLogin!(api);
            return;
          }
        }
        setState(() {
          _error = 'E-mail ou senha inválidos.';
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erro ao autenticar: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
        _loading = false;
      });
    }
  }

  void _onForgotPassword() {
    // TODO: Implementar ação de esqueci a senha
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de recuperação de senha em breve.')),
    );
  }

  void _onSignUp() {
    // TODO: Implementar ação de cadastro
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de cadastro em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      emailController: _emailController,
      passwordController: _passwordController,
      onLogin: _loading ? () {} : _login,
      loading: _loading,
      error: _error,
      onForgotPassword: _onForgotPassword,
      onSignUp: _onSignUp,
    );
  }
}
