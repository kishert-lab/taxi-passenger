import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:taxi_passenger/presentation/profile/bloc/passenger_profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PassengerProfileBloc>().add(
      const PassengerProfileLoadRequested(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: SafeArea(
        child: BlocConsumer<PassengerProfileBloc, PassengerProfileState>(
          listener: (context, state) {
            final passenger = state.passenger;
            if (passenger != null) {
              _nameController.text = passenger.name;
              _emailController.text = passenger.email;
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.passenger == null) {
              return const FullScreenLoader();
            }

            final passenger = state.passenger;
            if (passenger == null) {
              return const Center(child: Text('Профиль не найден'));
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: passenger.phone,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Телефон'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  if (state.errorMessage != null)
                    ErrorText(state.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () {
                            context.read<PassengerProfileBloc>().add(
                              PassengerProfileUpdateRequested(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                              ),
                            );
                          },
                    child: state.isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Сохранить'),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                      context.go('/auth/phone');
                    },
                    child: const Text('Выйти из аккаунта'),
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
