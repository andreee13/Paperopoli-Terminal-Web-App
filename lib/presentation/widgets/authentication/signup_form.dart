import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperopoli_terminal/cubits/authentication/authentication_cubit.dart';

class SignupFormWidget extends StatefulWidget {
  @override
  _SignupFormWidgetState createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _primaryPasswordController;
  late TextEditingController _secondaryPasswordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _primaryPasswordController = TextEditingController();
    _secondaryPasswordController = TextEditingController();
    _fullNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _primaryPasswordController.dispose();
    _secondaryPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  InputDecoration _getInputDecoration(
    String hintText,
    IconData icon,
  ) =>
      InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        fillColor: Colors.grey.withOpacity(0.2),
        filled: true,
        hintStyle: TextStyle(
          color: Colors.black45,
        ),
        hintText: hintText,
        suffixIcon: Icon(
          icon,
          color: Colors.black.withOpacity(0.7),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(7),
          ),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ship_icon_red.png',
                  height: 200,
                ),
                Text(
                  'Paperopoli Terminal',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 3,
              minHeight: MediaQuery.of(context).size.width / 4,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 30,
                    left: 30,
                    top: 40,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40,
                            bottom: 15,
                          ),
                          child: TextFormField(
                            controller: _fullNameController,
                            decoration: _getInputDecoration(
                              'Nome completo',
                              Ionicons.person_outline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 15,
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
                            bottom: 15,
                          ),
                          child: TextFormField(
                            controller: _primaryPasswordController,
                            decoration: _getInputDecoration(
                              'Password',
                              Ionicons.lock_closed_outline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 15,
                          ),
                          child: TextFormField(
                            controller: _secondaryPasswordController,
                            decoration: _getInputDecoration(
                              'Conferma password',
                              Ionicons.lock_closed_outline,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        Center(
                          child: MaterialButton(
                            onPressed: () async {
                              try {
                                await context
                                    .read<AuthenticationCubit>()
                                    .signUpWithCredentials(
                                      email: _emailController.text,
                                      password: _primaryPasswordController.text,
                                      fullName: _fullNameController.text,
                                    );
                                if (context.read<AuthenticationCubit>().state
                                    is AuthenticationNotLogged) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Impossibile completare la registrazione',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Impossibile completare la registrazione',
                                    ),
                                  ),
                                );
                              }
                            },
                            minWidth: MediaQuery.of(context).size.width / 6,
                            height: 48,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            color: Colors.blue.withOpacity(0.8),
                            elevation: 0,
                            highlightElevation: 0,
                            child: Text(
                              'Registrati',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      );
}
