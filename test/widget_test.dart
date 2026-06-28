import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/pages/login_screen.dart';
import 'package:the_old_reader/providers/provider_registry.dart';
import 'package:the_old_reader/providers/feed_provider.dart';

void main() {
  setUp(() {
    ProviderRegistry.register(
      'test_provider',
      () => throw UnimplementedError(),
      const ProviderInfo(
        id: 'test_provider',
        name: 'Test Provider',
        supportsWebProxy: false,
        authTypes: [AuthType.googleLogin],
      ),
    );
  });

  Widget buildLoginScreen({
    String? error,
    bool loading = false,
    VoidCallback? onLogin,
  }) {
    return MaterialApp(
      home: LoginScreen(
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
        apiKeyController: TextEditingController(),
        selectedProviderId: 'test_provider',
        availableProviders: ProviderRegistry.getAvailableProviders(),
        isApiKeyAuth: false,
        onProviderChanged: (_) {},
        onLogin: onLogin ?? () {},
        loading: loading,
        error: error,
      ),
    );
  }

  testWidgets('exibe campos de email e senha', (WidgetTester tester) async {
    await tester.pumpWidget(buildLoginScreen());

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('exibe botão Entrar habilitado', (WidgetTester tester) async {
    await tester.pumpWidget(buildLoginScreen());

    final botao = find.widgetWithText(ElevatedButton, 'Entrar');
    expect(botao, findsOneWidget);
    final button = tester.widget<ElevatedButton>(botao);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('exibe mensagem de erro', (WidgetTester tester) async {
    await tester.pumpWidget(buildLoginScreen(error: 'E-mail inválido'));

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('loading desabilita botão e mostra spinner', (WidgetTester tester) async {
    await tester.pumpWidget(buildLoginScreen(loading: true));

    final botao = find.widgetWithText(ElevatedButton, 'Entrar');
    expect(botao, findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
