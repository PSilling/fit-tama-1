import 'package:flutter/material.dart';

abstract class Editable<Widget extends StatefulWidget> implements State<Widget> {
  bool get isEditing;
  set isEditing(bool editing);
}

typedef WidgetKey = GlobalKey<Editable>;
