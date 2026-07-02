import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/data/api/public_legal_api.dart';
import 'package:taxi_passenger/data/repositories/legal_repository.dart';
import 'package:taxi_passenger/presentation/auth/bloc/auth_bloc.dart';

class AuthPhoneScreen extends StatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  State<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  final _controller = TextEditingController(text: '+7');
  late final Future<_AuthLegalBundle> _legalFuture;
  bool _consentAccepted = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _legalFuture = _loadLegalBundle();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<_AuthLegalBundle> _loadLegalBundle() async {
    final repository = context.read<LegalRepository>();
    final consent = await repository.loadConsent();
    final terms = await repository.loadTerms();
    return _AuthLegalBundle(consent: consent, terms: terms);
  }

  Future<void> _showDocument(LegalDocument document) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Версия ${document.version}'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(document.content),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool get _canSubmit => _consentAccepted && _termsAccepted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.codeRequested) {
              context.go('/auth/code', extra: state.phone);
            }
          },
          builder: (context, state) {
            return FutureBuilder<_AuthLegalBundle>(
              future: _legalFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const FullScreenLoader(
                    message: 'Загружаем документы...',
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Не удалось загрузить документы для авторизации',
                      ),
                    ),
                  );
                }

                final legal = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        'Вход по номеру телефона',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text('Введите номер, чтобы получить SMS-код'),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Телефон',
                          hintText: '+7 999 123-45-67',
                        ),
                      ),
                      const SizedBox(height: 20),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _consentAccepted,
                        onChanged: (value) {
                          setState(() => _consentAccepted = value ?? false);
                        },
                        title: const Text(
                          'Согласие на обработку персональных данных',
                        ),
                        subtitle: InkWell(
                          onTap: () => _showDocument(legal.consent),
                          child: Text(
                            'Открыть документ версии ${legal.consent.version}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() => _termsAccepted = value ?? false);
                        },
                        title: const Text(
                          'Принимаю пользовательское соглашение',
                        ),
                        subtitle: InkWell(
                          onTap: () => _showDocument(legal.terms),
                          child: Text(
                            'Открыть документ версии ${legal.terms.version}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (!_canSubmit)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Для продолжения нужно принять оба документа',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (state.errorMessage != null)
                        ErrorText(state.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            state.status == AuthStatus.loading || !_canSubmit
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                  AuthRequestCodeSubmitted(
                                    _controller.text.trim(),
                                  ),
                                );
                              },
                        child: state.status == AuthStatus.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Получить код'),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AuthLegalBundle {
  const _AuthLegalBundle({required this.consent, required this.terms});

  final LegalDocument consent;
  final LegalDocument terms;
}
