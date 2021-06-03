import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperopoli_terminal/cubits/goods/goods_cubit.dart';
import 'package:paperopoli_terminal/cubits/operations/operations_cubit.dart';
import 'package:paperopoli_terminal/cubits/people/people_cubit.dart';
import 'package:paperopoli_terminal/cubits/ships/ships_cubit.dart';
import 'package:paperopoli_terminal/cubits/trips/trips_cubit.dart';
import 'package:paperopoli_terminal/cubits/vehicles/vehicles_cubit.dart';
import 'package:paperopoli_terminal/data/repositories/goods_repository.dart';
import 'package:paperopoli_terminal/data/repositories/operations_repository.dart';
import 'package:paperopoli_terminal/data/repositories/people_repository.dart';
import 'package:paperopoli_terminal/data/repositories/ships_repository.dart';
import 'package:paperopoli_terminal/data/repositories/trips_repository.dart';
import 'package:paperopoli_terminal/data/repositories/vehicles_repository.dart';

import 'core/utils/constants.dart';
import 'core/utils/themes/default_theme.dart';
import 'cubits/authentication/authentication_cubit.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/screens/authentication_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await _initializeDeviceProperties();
  _initializeFirebaseMessaging();
  runZonedGuarded(
    () {
      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthenticationCubit(
                repository: UserRepository(
                  firebaseAuth: FirebaseAuth.instance,
                ),
              ),
            ),
            BlocProvider(
              create: (context) => ShipsCubit(
                repository: ShipsRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => GoodsCubit(
                repository: GoodsRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => VehiclesCubit(
                repository: VehiclesRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => OperationsCubit(
                repository: OperationsRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => TripsCubit(
                repository: TripsRepository(),
              ),
            ),
            BlocProvider(
              create: (context) => PeopleCubit(
                repository: PeopleRepository(),
              ),
            ),
          ],
          child: AppBootstrapper(),
        ),
      );
    },
    FirebaseCrashlytics.instance.recordError,
  );
}

Future<void> _initializeDeviceProperties() async {
  GestureBinding.instance!.resamplingEnabled = true;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

void _initializeFirebaseMessaging() {
  if (IS_WEB) {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      sound: true,
    );
  }
  FirebaseMessaging.onBackgroundMessage(
    _manageNotification,
  );
}

Future<void> _manageNotification(RemoteMessage msg) async => {};

class AppBootstrapper extends StatefulWidget {
  @override
  _AppBootstrapperState createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  @override
  void initState() {
    context.read<AuthenticationCubit>().login();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: DEFAULT_THEME,
        debugShowCheckedModeBanner: false,
        locale: Locale(
          'it',
          'IT',
        ),
        home: BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, state) {
            //return LandingScreen();
            if (state is AuthenticationError ||
                state is AuthenticationNotLogged) {
              return AuthenticatonScreen();
            } else if (state is AuthenticationLogged) {
              return HomeScreen();
            } else {
              return LoadingIndicator();
            }
          },
        ),
      );
}
