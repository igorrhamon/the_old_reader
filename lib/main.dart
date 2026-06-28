import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'providers/feed_provider.dart';
import 'providers/provider_init.dart';
import 'providers/provider_registry.dart';

import 'providers/auth/auth_config.dart';
import 'services/provider_settings.dart';

import 'pages/login_screen.dart';
import 'widget/feed_widget_service.dart';
import 'pages/favorites_page.dart';
import 'pages/add_feed_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/folders_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FeedWidgetService.initialize();
  initializeProviders();
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
      title: 'FeedFlow',
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
  FeedProvider? _provider;
  bool _loadingAuth = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final activeProviderId = await ProviderSettings.getActiveProvider();
      final providerId = activeProviderId ?? 'theoldreader';

      final storedAuth = await ProviderSettings.loadAuthConfig(providerId);
      if (storedAuth != null && storedAuth is GoogleLoginAuthConfig) {
        final provider = ProviderRegistry.create(providerId);
        if (provider != null) {
          final result = await provider.authenticate(storedAuth);
          if (result.success && mounted) {
            _onLogin(provider);
            return;
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingAuth = false);
  }

  void _onLogin(FeedProvider provider) {
    setState(() {
      _provider = provider;
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
    final isLogged = _provider != null;
    final providerName = _provider?.displayName ?? 'FeedFlow';
    if (_loadingAuth) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: _SplashScreen(),
      );
    }
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
            Text(providerName),
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
                MaterialPageRoute(builder: (_) => SearchPage(provider: _provider!)),
              ),
            ),
          if (isLogged)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sair',
              onPressed: () async {
                final providerId = _provider!.providerId;
                await _provider!.logout();
                await ProviderSettings.clearAuthConfig(providerId);
                setState(() => _provider = null);
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
                        Text(
                          providerName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                        ),
                      ],
                    ),
                  ),
                  _drawerItem(context, Icons.rss_feed_rounded, 'Feeds', 0),
                  ListTile(
                    leading: const Icon(Icons.folder_rounded, color: Color(0xFF8E8E93), size: 20),
                    title: const Text('Pastas', style: TextStyle(color: Color(0xFFF2F2F7), fontSize: 15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FoldersPage(provider: _provider!)),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                  _drawerItem(context, Icons.bookmark_rounded, 'Favoritos', 1),
                  _drawerItem(context, Icons.settings_rounded, 'Configurações', 2),
                ],
              ),
            )
          : null,
      body: isLogged
          ? Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: IndexedStack(
                    key: ValueKey(_selectedIndex),
                    index: _selectedIndex,
                    children: [
                      HomePage(provider: _provider!),
                      FavoritesPage(provider: _provider!),
                      SettingsPage(
                        provider: _provider!,
                        onLogout: () async {
                          final providerId = _provider!.providerId;
                          await _provider!.logout();
                          await ProviderSettings.clearAuthConfig(providerId);
                          setState(() => _provider = null);
                        },
                      ),
                    ],
                  ),
                ),
                if (_selectedIndex == 0)
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
                            builder: (context) => AddFeedPage(provider: _provider!),
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
  final void Function(FeedProvider provider)? onLogin;
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
      final provider = ProviderRegistry.create('theoldreader');
      if (provider == null) {
        setState(() {
          _error = 'Provider não disponível.';
          _loading = false;
        });
        return;
      }

      final config = GoogleLoginAuthConfig(
        providerId: 'theoldreader',
        email: email,
        password: password,
        authToken: '',
      );

      final result = await provider.authenticate(config);
      if (result.success) {
        await ProviderSettings.setActiveProvider('theoldreader');
        await ProviderSettings.saveAuthConfig('theoldreader', config);
        if (widget.onLogin != null) widget.onLogin!(provider);
        return;
      }

      setState(() {
        _error = result.error ?? 'E-mail ou senha inválidos.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro: $e';
        _loading = false;
      });
    }
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de recuperação de senha em breve.')),
    );
  }

  void _onSignUp() {
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF0F0F0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 140,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B2C),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
