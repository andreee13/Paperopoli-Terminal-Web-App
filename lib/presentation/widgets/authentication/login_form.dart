// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paperopoli_terminal/core/constants/keys.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flash/flash.dart';
import 'package:paperopoli_terminal/presentation/screens/authentication_screen.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  LoginFormWidgetState createState() => LoginFormWidgetState();
}

class LoginFormWidgetState extends State<LoginFormWidget> {
  bool _passwordVisible = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordResetController;

  @override
  void initState() {
    _emailController = TextEditingController(
      text: TEST_EMAIL,
    );
    _passwordController = TextEditingController(
      text: TEST_PASSWORD,
    );
    _passwordResetController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordResetController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration(
    String hintText,
    IconData icon,
  ) =>
      InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        fillColor: Colors.grey.withOpacity(0.1),
        filled: false,
        hintStyle: const TextStyle(
          color: Colors.black45,
        ),
        hintText: hintText,
        suffixIcon: icon == Icons.email_outlined
            ? Icon(
                icon,
                color: Colors.black.withOpacity(0.7),
                size: 20,
              )
            : IconButton(
                icon: Icon(
                  icon,
                ),
                onPressed: () => setState(() {
                  _passwordVisible = !_passwordVisible;
                }),
              ),
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          //borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xffD0C0D4).withOpacity(0.3),
              blurRadius: 128,
              spreadRadius: 64,
            ),
          ],
          borderRadius: BorderRadius.circular(
            24,
          ),
        ),
        padding: const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 16,
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 36,
                  color: Color(0xff242342),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 24,
                left: 8,
                right: 8,
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: _getInputDecoration(
                  'Email',
                  Icons.email_outlined,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 8,
                right: 8,
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: _getInputDecoration(
                  'Password',
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 8,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text(
                        'Recupero password',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Annulla',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Email inviata',
                                ),
                              ),
                            );
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _passwordResetController.text,
                            );
                          },
                          child: const Text(
                            'Invia',
                          ),
                        ),
                      ],
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Inserisci il tuo indirizzo email per il recupero password.',
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: TextFormField(
                                controller: _passwordResetController,
                                autofocus: true,
                                decoration: _getInputDecoration(
                                  'Email',
                                  Icons.email_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Password dimenticata?',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: MaterialButton(
                onPressed: () async {
                  await context.read<AuthenticationCubit>().logInWithCredentials(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                  var state = context.read<AuthenticationCubit>().state;
                  if (state is AuthenticationNotLogged || state is AuthenticationError) {
                    await context.showErrorBar(
                      content: const Text(
                        'Email o password errati',
                      ),
                    );
                  }
                },
                minWidth: 320,
                height: 56,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                color: const Color(0xff242342).withOpacity(0.7),
                elevation: 0,
                highlightElevation: 0,
                child: const Text(
                  'Accedi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Center(
              child: MaterialButton(
                onPressed: () => AuthenticatonScreen.of(context)!.setFormMode(true),
                minWidth: 320,
                height: 56,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                hoverElevation: 0,
                color: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                child: Text(
                  'Registrati',
                  style: TextStyle(
                    color: const Color(0xff242342).withOpacity(0.7),
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
