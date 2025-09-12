import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyCode  = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code  = TextEditingController();

  bool _codeSent = false;
  bool _busy = false;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer([int seconds = 60]) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _doRegister() async {
    if (_formKeyEmail.currentState?.validate() != true) return;
    setState(() => _busy = true);
    final err = await ref.read(authStateProvider.notifier)
        .registerEmail(_email.text.trim(), sendCodeAfter: true);
    setState(() => _busy = false);

    if (err == null) {
      setState(() {
        _codeSent = true;
        _code.clear();
      });
      _startTimer(60);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada (ou já existia) e código enviado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _sendCode() async {
    if (_formKeyEmail.currentState?.validate() != true) return;
    setState(() => _busy = true);
    final err = await ref.read(authStateProvider.notifier)
        .requestCode(_email.text.trim());
    setState(() => _busy = false);

    if (err == null) {
      setState(() {
        _codeSent = true;
        _code.clear();
      });
      _startTimer(60);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código enviado. Veja seu e-mail.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _verifyCode() async {
    if (_formKeyCode.currentState?.validate() != true) return;
    await ref.read(authStateProvider.notifier)
        .verifyCode(_email.text.trim(), _code.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (auth.error != null) ...[
                  Text(auth.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],

                // E-mail
                Form(
                  key: _formKeyEmail,
                  child: TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email inválido' : null,
                    enabled: !_codeSent && !_busy && auth.status != AuthStatus.authenticating,
                  ),
                ),
                const SizedBox(height: 12),


                if (_codeSent) ...[
                  Form(
                    key: _formKeyCode,
                    child: TextFormField(
                      controller: _code,
                      decoration: const InputDecoration(labelText: 'Código (6 dígitos)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (v) =>
                      (v == null || v.length != 6) ? 'Informe os 6 dígitos' : null,
                      enabled: !_busy && auth.status != AuthStatus.authenticating,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],


                if (!_codeSent) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_busy || auth.status == AuthStatus.authenticating) ? null : _doRegister,
                      child: Text(_busy ? 'Aguarde...' : 'Criar conta'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: (_busy || auth.status == AuthStatus.authenticating) ? null : _sendCode,
                      child: const Text('Enviar código'),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_busy || auth.status == AuthStatus.authenticating) ? null : _verifyCode,
                      child: Text(auth.status == AuthStatus.authenticating ? 'Verificando...' : 'Entrar'),
                    ),
                  ),
                  TextButton(
                    onPressed: (_secondsLeft == 0 && !_busy && auth.status != AuthStatus.authenticating)
                        ? _sendCode
                        : null,
                    child: Text(_secondsLeft == 0 ? 'Reenviar código' : 'Reenviar em $_secondsLeft s'),
                  ),
                  TextButton(
                    onPressed: (_busy || auth.status == AuthStatus.authenticating) ? null : () {
                      setState(() {
                        _codeSent = false;
                        _timer?.cancel();
                        _secondsLeft = 0;
                      });
                    },
                    child: const Text('Trocar e-mail'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
