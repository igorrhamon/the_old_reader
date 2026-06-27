import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/pages/login_screen.dart';

Widget buildLoginScreen({
  String? error,
  bool loading = false,
  VoidCallback? onLogin,
}) {
  return MaterialApp(
    home: LoginScreen(
      emailController: TextEditingController(),
      passwordController: TextEditingController(),
      onLogin: onLogin ?? () {},
      loading: loading,
      error: error,
    ),
  );
}

void main() {
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
