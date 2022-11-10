import 'package:flutter/cupertino.dart';

/// Creates a Material icon from its icon code.
Icon iconFromCode({int iconCode = 0xe046, Color? color, double? size}) => Icon(
      IconData(iconCode, fontFamily: 'MaterialIcons'),
      color: color,
      size: size,
    );
