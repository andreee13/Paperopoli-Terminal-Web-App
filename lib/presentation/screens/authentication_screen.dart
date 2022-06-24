import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paperopoli_terminal/presentation/widgets/authentication/login_form.dart';
import 'package:paperopoli_terminal/presentation/widgets/authentication/signup_form.dart';

class AuthenticatonScreen extends StatefulWidget {
  const AuthenticatonScreen({Key? key}) : super(key: key);

  @override
  AuthenticatonScreenState createState() => AuthenticatonScreenState();

  static AuthenticatonScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<AuthenticatonScreenState>();
}

class AuthenticatonScreenState extends State<AuthenticatonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _inSignupMode = false;

  void setFormMode(bool b) => setState(
        () => _inSignupMode = b,
      );

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(
        seconds: 1,
      ),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
    Future.delayed(
      const Duration(
        seconds: 1,
      ),
      () {
        try {
          _controller.forward();
        } catch (_) {}
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xffFDFCFD),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          onPressed: () {},
          child: const Icon(
            Icons.help_outline_outlined,
            color: Colors.black,
          ),
        ),
        body: Stack(
          children: [
            FadeTransition(
              opacity: _animation,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/landing.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  bottom: 16,
                ),
                child: Text(
                  'Copyright © 2021 Andrea Checchin',
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ship_icon.png',
                      width: 170,
                      color: const Color(0xff5564E8).withOpacity(0.7),
                    ),
                    Text(
                      'Paperopoli Terminal',
                      style: GoogleFonts.nunito(
                        fontSize: 56,
                        color: const Color(0xff242342),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Container(
                      width: 380,
                      margin: const EdgeInsets.only(
                        top: 80,
                      ),
                      child: _inSignupMode ? const SignUpFormWidget() : const LoginFormWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
