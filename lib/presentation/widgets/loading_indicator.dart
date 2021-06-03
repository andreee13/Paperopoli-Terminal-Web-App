import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator();

  @override
  Widget build(BuildContext context) => Center(
        child: Lottie.network(
          'https://assets7.lottiefiles.com/packages/lf20_ikj1qt.json',
          height: 100,
          width: 100,
        ),
      );
}
