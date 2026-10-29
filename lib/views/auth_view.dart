import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_controller.dart';
import '../theme/app_theme.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _createMode = false;
  bool _resetMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthController>();
    if (_resetMode) {
      await auth.sendPasswordReset(_emailController.text);
    } else if (_createMode) {
      await auth.createAccount(_emailController.text, _passwordController.text);
    } else {
      await auth.signInWithEmail(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.needsVerification) return _VerificationPanel(auth: auth);
    return Scaffold(
      backgroundColor: BmsColors.shell,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return Row(
              children: [
                if (!compact) const Expanded(flex: 4, child: _AuthBrandPanel()),
                Expanded(
                  flex: compact ? 1 : 6,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 60, vertical: compact ? 30 : 52),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 470),
                        child: _AuthForm(
                          auth: auth,
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmController: _confirmController,
                          createMode: _createMode,
                          resetMode: _resetMode,
                          obscurePassword: _obscurePassword,
                          onToggleMode: () => setState(() {
                            _createMode = !_createMode;
                            _resetMode = false;
                          }),
                          onToggleReset: () => setState(() => _resetMode = !_resetMode),
                          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                          onSubmit: _submit,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF102A3B),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 58, 56, 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandLockup(light: true),
                  const Spacer(),
                  const Text(
                    'Clear visibility\nfor every\noperating cycle.',
                    style: TextStyle(color: Colors.white, fontSize: 42, height: 1.08, fontWeight: FontWeight.w700, letterSpacing: -1.2),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'A focused monitoring workspace for battery system operators.\nReview health, events, and telemetry in one place.',
                    style: TextStyle(color: Colors.white.withValues(alpha: .66), fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 38),
                  const Row(children: [_Signal(label: 'SECURE ACCESS'), SizedBox(width: 22), _Signal(label: 'READ-ONLY CONSOLE')]),
                ],
              ),
            ),
          ],
        ),
      );
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.auth, required this.formKey, required this.emailController, required this.passwordController, required this.confirmController, required this.createMode, required this.resetMode, required this.obscurePassword, required this.onToggleMode, required this.onToggleReset, required this.onTogglePassword, required this.onSubmit});
  final AuthController auth;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool createMode;
  final bool resetMode;
  final bool obscurePassword;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleReset;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandLockup(),
          const SizedBox(height: 48),
          Text(resetMode ? 'Reset your password' : createMode ? 'Create operator account' : 'Sign in to your console', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -.7)),
          const SizedBox(height: 9),
          Text(resetMode ? 'We will send a secure reset link to your email.' : 'Access the BMS Monitor workspace securely.', style: const TextStyle(color: BmsColors.muted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 26),
          if (auth.errorMessage != null) ...[_MessageBanner(message: auth.errorMessage!), const SizedBox(height: 16)],
          if (!resetMode) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(onPressed: auth.isBusy ? null : auth.signInWithGoogle, icon: const Icon(Icons.g_mobiledata_rounded, size: 26), label: const Text('CONTINUE WITH GOOGLE')),
            ),
            const SizedBox(height: 22),
            const _DividerLabel('OR CONTINUE WITH EMAIL'),
            const SizedBox(height: 20),
          ],
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('WORK EMAIL'),
                const SizedBox(height: 8),
                TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], validator: (value) => value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim()) ? 'Enter a valid email address.' : null, decoration: _inputDecoration('operator@company.com', Icons.alternate_email_rounded)),
                if (!resetMode) ...[
                  const SizedBox(height: 18),
                  const _FieldLabel('PASSWORD'),
                  const SizedBox(height: 8),
                  TextFormField(controller: passwordController, obscureText: obscurePassword, autofillHints: const [AutofillHints.password], onFieldSubmitted: (_) => onSubmit(), validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters.' : null, decoration: _inputDecoration('Enter your password', Icons.lock_outline_rounded).copyWith(suffixIcon: IconButton(tooltip: obscurePassword ? 'Show password' : 'Hide password', onPressed: onTogglePassword, icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
                ],
                if (createMode && !resetMode) ...[
                  const SizedBox(height: 18),
                  const _FieldLabel('CONFIRM PASSWORD'),
                  const SizedBox(height: 8),
                  TextFormField(controller: confirmController, obscureText: true, validator: (value) => value != passwordController.text ? 'Passwords do not match.' : null, decoration: _inputDecoration('Repeat your password', Icons.lock_reset_outlined)),
                ],
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: auth.isBusy ? null : onSubmit, child: auth.isBusy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : Text(resetMode ? 'SEND RESET LINK' : createMode ? 'CREATE ACCOUNT' : 'SIGN IN'))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!createMode && !resetMode) Center(child: TextButton(onPressed: onToggleReset, child: const Text('Forgot password?'))),
          Center(child: TextButton(onPressed: onToggleMode, child: Text(createMode ? 'Already have an account? Sign in' : 'New operator? Create an account'))),
          if (resetMode) Center(child: TextButton(onPressed: onToggleReset, child: const Text('Back to sign in'))),
          const SizedBox(height: 16),
          const Center(child: Text('BMS MONITOR  •  SECURE READ-ONLY ACCESS', style: TextStyle(color: BmsColors.dim, fontSize: 10, letterSpacing: 1.1))),
        ],
      );
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({required this.auth});
  final AuthController auth;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: BmsColors.shell,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandLockup(),
                  const SizedBox(height: 42),
                  const Text('Verify your email', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('We sent a verification link to ${auth.email ?? 'your email address'}. Verify it before entering the dashboard.', style: const TextStyle(color: BmsColors.muted, height: 1.5)),
                  const SizedBox(height: 24),
                  if (auth.errorMessage != null) _MessageBanner(message: auth.errorMessage!),
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: auth.isBusy ? null : auth.refreshVerification, child: const Text('I VERIFIED MY EMAIL'))),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, height: 50, child: OutlinedButton(onPressed: auth.isBusy ? null : auth.resendVerification, child: const Text('RESEND VERIFICATION EMAIL'))),
                  const SizedBox(height: 8),
                  Center(child: TextButton(onPressed: auth.isBusy ? null : auth.logout, child: const Text('Use a different account'))),
                ],
              ),
            ),
          ),
        ),
      );
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({this.light = false});
  final bool light;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: BmsColors.teal.withValues(alpha: .15), borderRadius: BorderRadius.circular(9), border: Border.all(color: BmsColors.teal.withValues(alpha: .75))), child: const Icon(Icons.battery_charging_full_rounded, color: BmsColors.teal, size: 21)), const SizedBox(width: 11), Text('BMS MONITOR', style: TextStyle(color: light ? Colors.white : BmsColors.text, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: .3))]);
}

class _Signal extends StatelessWidget {
  const _Signal({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.circle, color: BmsColors.teal, size: 7), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: .4))]);
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: BmsColors.dim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1));
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Row(children: [const Expanded(child: Divider(color: BmsColors.border)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(label, style: const TextStyle(color: BmsColors.dim, fontSize: 10, letterSpacing: .8))), const Expanded(child: Divider(color: BmsColors.border))]);
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: BmsColors.critical.withValues(alpha: .12), borderRadius: BorderRadius.circular(10), border: Border.all(color: BmsColors.critical.withValues(alpha: .4))), child: Text(message, style: const TextStyle(color: BmsColors.critical, fontSize: 12)));
}

InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: BmsColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: BmsColors.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: BmsColors.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: BmsColors.teal, width: 1.5)));

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .055)..strokeWidth = 1;
    for (var x = 40.0; x < size.width; x += 84) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (var y = 40.0; y < size.height; y += 84) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
