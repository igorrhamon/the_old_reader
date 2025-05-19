import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'old_reader_api.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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
                    const Center(child: Text('Favoritos (em breve)', style: TextStyle(fontSize: 18))),
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
  final _secureStorage = kIsWeb 
    ? FlutterSecureStorage(
        webOptions: const WebOptions(
          dbName: 'FlutterEncryptedStorage',
          publicKey: 'FlutterSecureStorage',
          wrapKey: '',
          wrapKeyIv: '',
        ),
      )
    : FlutterSecureStorage(
        iOptions: const IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final token = await _secureStorage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      final api = OldReaderApi(token);
      final userInfo = await api.getUserInfo();
      if (userInfo.statusCode == 200) {
        if (widget.onLogin != null) widget.onLogin!(api);
      }
    }
  }
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
          await _secureStorage.write(key: 'auth_token', value: token);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !_loading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Entrar'),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
