// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flash/flash.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';
import 'package:paperopoli_terminal/presentation/screens/authentication_screen.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({Key? key}) : super(key: key);

  @override
  SignUpFormWidgetState createState() => SignUpFormWidgetState();
}

class SignUpFormWidgetState extends State<SignUpFormWidget> {
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _passwordResetController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController1.dispose();
    _passwordController2.dispose();
    _fullNameController.dispose();
    _passwordResetController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration(
    String hintText,
    IconData icon,
    int? index,
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
        suffixIcon: index == null
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
                  if (index == 0) {
                    _passwordVisible1 = !_passwordVisible1;
                  } else if (index == 1) {
                    _passwordVisible2 = !_passwordVisible2;
                  }
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
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      top: 12,
                    ),
                    child: IconButton(
                      onPressed: () => AuthenticatonScreen.of(context)!.setFormMode(false),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff242342),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                    ),
                    child: Text(
                      'Registrazione',
                      style: TextStyle(
                        fontSize: 32,
                        color: Color(0xff242342),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 24,
                left: 8,
                right: 8,
              ),
              child: TextFormField(
                controller: _fullNameController,
                decoration: _getInputDecoration(
                  'Nome completo',
                  Icons.person_outline,
                  null,
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
                controller: _emailController,
                decoration: _getInputDecoration(
                  'Email',
                  Icons.email_outlined,
                  null,
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
                controller: _passwordController1,
                obscureText: !_passwordVisible1,
                decoration: _getInputDecoration(
                  'Password',
                  _passwordVisible1 ? Icons.visibility_off : Icons.visibility,
                  0,
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
                controller: _passwordController2,
                obscureText: !_passwordVisible2,
                decoration: _getInputDecoration(
                  'Conferma password',
                  _passwordVisible2 ? Icons.visibility_off : Icons.visibility,
                  1,
                ),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Center(
              child: MaterialButton(
                onPressed: () async {
                  if (_fullNameController.text.isNotEmpty) {
                    if (_emailController.text.isNotEmpty) {
                      if (_passwordController1.text.isNotEmpty &&
                          _passwordController2.text.isNotEmpty) {
                        if (_passwordController1.text == _passwordController2.text) {
                          await context.read<AuthenticationCubit>().signUpWithCredentials(
                                email: _emailController.text,
                                password: _passwordController1.text,
                                fullName: _fullNameController.text,
                              );
                          var state = context.read<AuthenticationCubit>().state;
                          if (state is AuthenticationNotLogged || state is AuthenticationError) {
                            await context.showErrorBar(
                              content: const Text(
                                'Ricontrolla i dati',
                              ),
                            );
                          }
                        } else {
                          await context.showErrorBar(
                            content: const Text(
                              'Le password devono corrispondere',
                            ),
                          );
                        }
                      } else {
                        await context.showErrorBar(
                          content: const Text(
                            'Inserire le password richieste',
                          ),
                        );
                      }
                    } else {
                      await context.showErrorBar(
                        content: const Text(
                          'Inserire l\'indirizzo email',
                        ),
                      );
                    }
                  } else {
                    await context.showErrorBar(
                      content: const Text(
                        'Inserire il nome completo',
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
                  'Registrati',
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
          ],
        ),
      );
}
