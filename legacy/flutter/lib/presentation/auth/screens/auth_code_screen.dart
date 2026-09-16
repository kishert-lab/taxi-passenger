import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/presentation/auth/bloc/auth_bloc.dart';

class AuthCodeScreen extends StatefulWidget {
  const AuthCodeScreen({super.key, required this.phone});

  final String phone;

  @override
  State<AuthCodeScreen> createState() => _AuthCodeScreenState();
}

class _AuthCodeScreenState extends State<AuthCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go('/home');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Подтверждение',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text('Код отправлен на ${widget.phone}'),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'SMS-код'),
                  ),
                  const SizedBox(height: 16),
                  if (state.errorMessage != null)
                    ErrorText(state.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.status == AuthStatus.loading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                              AuthConfirmCodeSubmitted(
                                phone: widget.phone,
                                code: _controller.text.trim(),
                              ),
                            );
                          },
                    child: state.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Подтвердить'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
