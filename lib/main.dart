import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/old_reader_api.dart';
import 'services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pages/favorites_page.dart';
import 'pages/add_feed_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6B2C);
    const bg = Color(0xFF0F0F0F);
    const surface = Color(0xFF1C1C1E);
    const surfaceHigh = Color(0xFF2C2C2E);
    const textPrimary = Color(0xFFF2F2F7);
    const textSecondary = Color(0xFF8E8E93);
    const outline = Color(0xFF3A3A3C);

    return MaterialApp(
      title: 'The Old Reader',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          onPrimary: Colors.white,
          secondary: textSecondary,
          onSecondary: Colors.white,
          surface: surface,
          onSurface: textPrimary,
          surfaceContainerHighest: surfaceHigh,
          onSurfaceVariant: textSecondary,
          outline: outline,
          error: Color(0xFFFF453A),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textSecondary),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: Color(0x33FF6B2C),
          iconTheme: WidgetStatePropertyAll(IconThemeData(color: textSecondary)),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(color: textSecondary, fontSize: 11),
          ),
        ),
        dividerColor: outline,
        cardTheme: const CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.5),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.2),
          titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 13),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.6),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
          bodySmall: TextStyle(color: textSecondary, fontSize: 11),
          labelLarge: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
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
  bool _loadingAuth = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await AuthService.loadToken();
      if (token != null && token.isNotEmpty) {
        final api = OldReaderApi(token);
        try {
          final info = await api.getUserInfo();
          if (info.statusCode == 200) {
            if (mounted) _onLogin(api);
            return;
          }
        } catch (_) {}
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingAuth = false);
  }

  void _onLogin(OldReaderApi api) {
    setState(() {
      _api = api;
      _selectedIndex = 0;
      _loadingAuth = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFFFF6B2C) : const Color(0xFF8E8E93), size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFFFF6B2C) : const Color(0xFFF2F2F7),
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15,
        ),
      ),
      selectedTileColor: const Color(0x1AFF6B2C),
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () {
        Navigator.pop(context);
        _onTabTapped(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogged = _api != null;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B2C),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('The Old Reader'),
          ],
        ),
        centerTitle: true,
        actions: [
          if (isLogged)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Buscar',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchPage(api: _api!)),
              ),
            ),
          if (isLogged)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sair',
              onPressed: () async {
                await AuthService.clearToken();
                setState(() => _api = null);
              },
            ),
        ],
      ),
      drawer: isLogged
          ? Drawer(
              backgroundColor: const Color(0xFF1C1C1E),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Color(0xFF0F0F0F)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B2C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.rss_feed, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The Old Reader',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                  _drawerItem(context, Icons.rss_feed_rounded, 'Feeds', 0),
                  _drawerItem(context, Icons.bookmark_rounded, 'Favoritos', 1),
                  _drawerItem(context, Icons.settings_rounded, 'Configurações', 2),
                ],
              ),
            )
          : null,
      body: _loadingAuth
          ? const Center(child: CircularProgressIndicator())
          : isLogged
          ? Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: [
                    HomePage(api: _api!),
                    FavoritesPage(api: _api!),
                    SettingsPage(
                      api: _api!,
                      onLogout: () async {
                        await AuthService.clearToken();
                        setState(() => _api = null);
                      },
                    ),
                  ],
                ),                  if (_selectedIndex == 0)
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFFFF6B2C),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFeedPage(api: _api!),
                            ),
                          );
                          if (result == true) setState(() {});
                        },
                        tooltip: 'Adicionar feed',
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
              ],
            )
          : LoginPage(onLogin: _onLogin),
      bottomNavigationBar: isLogged
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onTabTapped,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.rss_feed_outlined),
                  selectedIcon: Icon(Icons.rss_feed_rounded, color: Color(0xFFFF6B2C)),
                  label: 'Feeds',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded, color: Color(0xFFFF6B2C)),
                  label: 'Favoritos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFFFF6B2C)),
                  label: 'Config.',
                ),
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
      final authBase = kIsWeb ? 'http://localhost:3000/proxy' : 'https://theoldreader.com';
      final url = Uri.parse('$authBase/accounts/ClientLogin');
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
            await AuthService.saveToken(token);
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
