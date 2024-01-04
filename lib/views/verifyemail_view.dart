import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Email Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                  "We've sent you an Email verification. Please  open it to verify your account "),
              const Text("If you haven't received. Click the button below"),
              Center(
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventSendEmailVerification(),
                              );
                        },
                        child: const Text('Send Email For Verification ')),
                    TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        },
                        child: const Text('Restart'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
