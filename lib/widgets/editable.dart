import 'package:flutter/material.dart';

abstract class Editable<Widget extends StatefulWidget> implements State<Widget> {
  bool getEditing();
  void setEditing(bool editing);
}
