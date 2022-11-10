import 'package:flutter/material.dart';

/// Has a size of widest possible text of in given font
class FontSpacer extends StatelessWidget {
  final String text;
  final TextStyle? style;

  /// Just has a size of given text in given font
  const FontSpacer({super.key, required this.text, required this.style});

  /// Has a size of widest possible text of given number of characters in given font
  factory FontSpacer.widest(
      {Key? key,
      required int characterWidth,
      FontSpacerPurpose purpose = FontSpacerPurpose.any,
      required TextStyle? style}) {
    return FontSpacer(key: key, text: List.filled(characterWidth, purpose.character).join(), style: style);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0,
      child: Text(text, style: style),
    );
  }
}

enum FontSpacerPurpose {
  any,
  number;

  /// Widest character of type
  String get character {
    switch (this) {
      case FontSpacerPurpose.any:
        return "M";
      case FontSpacerPurpose.number:
        return "4";
    }
  }
}
