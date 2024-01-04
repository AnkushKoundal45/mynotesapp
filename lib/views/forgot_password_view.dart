import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateForgotPassword) {
            if (state.hasSentEmail) {
              _controller.clear();
              await showPasswordResetDialog(context);
            }
            if (state.exception != null) {
              log(state.exception.toString());
              if (state.exception is InvalidLoginCredentials) {
                return await showErrorDialog(
                    context, 'Invalid E-mail or Password');
              } else if (state.exception is ChannelErrorAuthException) {
                return await showErrorDialog(
                    context, 'Enter your E-mail or Password');
              } else if (state.exception is InvalidEmailAuthException) {
                return await showErrorDialog(context, 'Invalid E-mail');
              } else if (state.exception is GenericAuthException) {
                return await showErrorDialog(context, 'Authentication Error');
              }
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Forgot Password'),
            backgroundColor: Colors.red,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                    'If you forgot your password please enter your email and we will send you an email for password reset.'),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter Your Email Here',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;

                    context
                        .read<AuthBloc>()
                        .add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text('Send me email for password reset'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  },
                  child: const Text('Back to login page'),
                ),
              ],
            ),
          ),
        ));
  }
}
