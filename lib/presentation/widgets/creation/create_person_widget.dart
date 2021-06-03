import 'package:flutter/cupertino.dart';

class CreatePersonWidget extends StatefulWidget {
  @override
  _CreatePersonWidgetState createState() => _CreatePersonWidgetState();
}

class _CreatePersonWidgetState extends State<CreatePersonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'New person',
      ),
    );
  }
}
