import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key, this.message}) : super(key: key);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String? messageValue = message;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Center(
          child: SizedBox(
            width: 8.0 * 10,
            height: 8.0 * 10,
            child: CircularProgressIndicator(),
          ),
        ),
        if (messageValue != null) const SizedBox(height: 8.0 * 4),
        if (messageValue != null)
          Text(
            messageValue,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
