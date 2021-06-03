import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginFormWidget extends StatefulWidget {
  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _passwordVisible = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordResetController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
        hintStyle: TextStyle(
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
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
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
              color: Color(0xffD0C0D4).withOpacity(0.3),
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
            Padding(
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: Text(
                'LOGIN',
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
            SizedBox(
              height: 40,
            ),
            Center(
              child: MaterialButton(
                onPressed: () async {
                  try {
                    await context
                        .read<AuthenticationCubit>()
                        .logInWithCredentials(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                    if (context.read<AuthenticationCubit>().state
                        is AuthenticationNotLogged) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Password/email incorretti',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Si è verificato un errore',
                        ),
                      ),
                    );
                  }
                },
                minWidth: 320,
                height: 56,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                color: Color(0xff242342).withOpacity(0.7),
                elevation: 0,
                highlightElevation: 0,
                child: Text(
                  'Accedi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 24,
                right: 8,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Recupero password',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Annulla',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Email inviata',
                                ),
                              ),
                            );
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _passwordResetController.text,
                            );
                          },
                          child: Text(
                            'Invia',
                          ),
                        ),
                      ],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Inserisci il tuo indirizzo email per il recupero password.',
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
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
                  child: Text(
                    'Password dimenticata?',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
