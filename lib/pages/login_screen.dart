import 'package:flutter/material.dart';

const _accent = Color(0xFFFF6B2C);
const _bg = Color(0xFF0F0F0F);
const _surface = Color(0xFF1C1C1E);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool loading;
  final String? error;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  const LoginScreen({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    this.loading = false,
    this.error,
    this.onForgotPassword,
    this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo mark
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 28),
              const Text(
                'Entrar',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The Old Reader',
                style: TextStyle(
                  color: _accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 36),
              _label('E-mail'),
              const SizedBox(height: 8),
              _field(
                controller: emailController,
                hint: 'seu@email.com',
                keyboardType: TextInputType.emailAddress,
                enabled: !loading,
              ),
              const SizedBox(height: 16),
              _label('Senha'),
              const SizedBox(height: 8),
              _field(
                controller: passwordController,
                hint: '••••••••',
                obscure: true,
                enabled: !loading,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onForgotPassword,
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 28),
              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF453A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x33FF453A)),
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Color(0xFFFF453A), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF5C3A20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: onSignUp,
                  child: const Text.rich(
                    TextSpan(
                      text: 'Não tem conta? ',
                      style: TextStyle(color: _textSecondary, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Cadastrar',
                          style: TextStyle(color: _accent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textPrimary, fontSize: 15),
      cursorColor: _accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
      ),
    );
  }
}
