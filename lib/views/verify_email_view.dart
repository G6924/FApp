
import 'package:flutter/material.dart';
import 'package:project/constants/routes.dart';
import 'package:project/services/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/services/auth/bloc/auth_bloc.dart';
import 'package:project/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({ Key? key }) : super(key: key);

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email'),),
      body: Column(
        children: [
          const Text(
              "we've sent you an email verification. please open it to verify your account"),
          const Text(
              "if you haven't received a verification email yet, press the button bellow "),
          TextButton(
            onPressed: () async {
             context.read<AuthBloc>().add(
               const AuthEventSendEmailVerification(),
             );
            },
            child: const Text('Send email verifications'),
          ),
          TextButton(onPressed: () async {
            context.read<AuthBloc>().add(
              const AuthEventLogOut(),
            );
          },
              child: const Text('restart'),
          ),
        ],
      ),
    );
  }
}

