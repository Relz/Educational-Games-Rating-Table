import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../core/layout/adaptive.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({
    required this.title,
    required this.color,
    Key? key,
  }) : super(key: key);

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = isDisplayDesktop(context)
        ? Theme.of(context).primaryTextTheme.headline6
        : Theme.of(context).primaryTextTheme.bodyText1;

    return DottedBorder(
      color: Colors.white,
      borderType: BorderType.RRect,
      radius: const Radius.circular(8.0 * 3),
      child: Container(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 8.0 * 0.5,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0 * 3),
        ),
        child: Text(title, style: textStyle),
      ),
    );
  }
}
