import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'Enter Your Email Here'),
            controller: _email,
          ),
          TextField(
            decoration:
                const InputDecoration(hintText: 'Enter Your Password Here'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: _password,
          ),
          TextButton(
              onPressed: () async {
                try {
                  final email = _email.text;
                  final password = _password.text;
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, password: password);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user?.emailVerified ?? false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      mynotesRoute,
                      (route) => false,
                    ); //  user email is verified
                  } else {
                    Navigator.of(context).pushNamed(
                      verifyemailRoute,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
                    return await showErrorDialog(
                      context,
                      'Invalid E-mail or Password',
                    );
                  } else if (e.code == 'invalid-email') {
                    return await showErrorDialog(
                      context,
                      'Invalid E-mail',
                    );
                  } else if (e.code == 'channel-error') {
                    return await showErrorDialog(
                      context,
                      'Enter your E-mail or Password',
                    );
                  } else {
                    return await showErrorDialog(
                      context,
                      'Error: ${e.code}',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    context,
                    e.toString(),
                  );
                }
              },
              child: const Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not registered yet? Register Here!')),
        ],
      ),
    );
  }
}
