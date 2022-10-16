import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tabletop_assistant/helpers.dart';
import 'package:tabletop_assistant/widgets/counter_widget/counter_widget_data.dart';

class CounterEditDialog extends StatefulWidget {
  final CounterWidgetData data;
  final void Function(CounterWidgetData) setData;

  const CounterEditDialog({super.key, required this.data, required this.setData});

  @override
  State<StatefulWidget> createState() => _CounterEditDialogState();
}

class _CounterEditDialogState extends State<CounterEditDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  late bool _isUneven;
  late List<KeyedEntry> _keyedScale;
  late final GlobalKey? _defaultIndexKey;
  GlobalKey? _hiddenCurrentIndexKey;

  late final _rangeInitialValue = IntRange.from(scale: widget.data.scale);
  final _rangeDefaultSliderKey = GlobalKey<FormBuilderFieldState>();
  static const _defaultEntryOption = FormBuilderChipOption<String>(value: "Default");

  @override
  void initState() {
    _isUneven = widget.data.isUneven;
    if (widget.data.isUneven) {
      final defaultScale = widget.data.scale.map((element) => KeyedEntry(value: element)).toList();
      _keyedScale = defaultScale + [KeyedEntry(value: null)];
      _defaultIndexKey = defaultScale[widget.data.defaultIndex].checkKey;
    } else {
      _keyedScale = [];
      _defaultIndexKey = null;
    }
    super.initState();
  }

  String? _numberValidator(String? value, {bool isRequired = true}) {
    if (value == null) {
      return isRequired ? "This field cannot be empty" : null;
    }
    final number = int.tryParse(value);
    if (number == null) {
      return "Input must be an integer";
    }
    return null;
  }

  String? _rangeValidator(IntRange? range) {
    return (range != null) ? null : "Range must be set";
  }

  String? _scaleValidator(Key? key, {required List<KeyedEntry> scale}) {
    final isScaleEmpty = scale.every((element) => element.value == null);
    if (isScaleEmpty) {
      return "Scale cannnot be empty";
    } else if (key == null) {
      return "You have to choose a default value";
    } else {
      return null;
    }
  }

  void _validateSaveAndDismiss(BuildContext context) {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    if (formState.validate()) {
      formState.save();
      widget.setData(widget.data);
      Navigator.of(context).pop();
    }
  }

  void _cleanTempScale() {
    final newState =
        _keyedScale.compactMap((element) => (element == _keyedScale.last || element.value != null) ? element : null);
    setState(() {
      final focused = FocusScope.of(context).focusedChild;
      if (!newState.map((e) => e.focusNode).contains(focused)) {
        FocusScope.of(context).previousFocus();
      }
      _keyedScale = List.from(newState);
    });
  }

  void _updateTempScale(String? value, KeyedEntry entry, FormFieldState field) {
    final newValue = value.flatMap((value) => int.tryParse(value));
    _keyedScale.firstWhere((element) => element.textKey == entry.textKey).value = newValue;
    if (_keyedScale.last.textKey == entry.textKey && newValue != null) {
      _keyedScale.add(KeyedEntry(value: null));
    }
    if (newValue == null && field.value == entry.checkKey) {
      field.didChange(null);
      _hiddenCurrentIndexKey = entry.checkKey;
    } else if (newValue != null && _hiddenCurrentIndexKey == entry.checkKey) {
      field.didChange(_hiddenCurrentIndexKey);
      _hiddenCurrentIndexKey = null;
    }
  }

  void _rangeStartChanged(String? value, FormFieldState<IntRange> field) {
    if (value == null || value.isEmpty) {
      return;
    }
    final range = IntRange(int.tryParse(value), field.value?.end);
    final defaultSliderState = _rangeDefaultSliderKey.currentState;
    final rangeStart = range.start;
    final rangeEnd = range.end;
    if (defaultSliderState != null && rangeStart != null && rangeEnd != null) {
      final sliderValue = defaultSliderState.value;
      final isStartToEnd = rangeStart < rangeEnd;
      final isBelowStart = isStartToEnd && sliderValue < rangeStart;
      final isAboveEnd = isStartToEnd && field.value!.end! < sliderValue;
      final isEndToStart = rangeEnd < rangeStart;
      final isAboveStart = isEndToStart && rangeStart < sliderValue;
      final isBelowEnd = isEndToStart && sliderValue < rangeEnd;
      if (isBelowStart || isAboveStart) {
        defaultSliderState.didChange(rangeStart.toDouble());
      } else if (isAboveEnd || isBelowEnd) {
        defaultSliderState.didChange(rangeEnd.toDouble());
      }
    }
    field.didChange(range);
  }

  void _rangeEndChanged(String? value, FormFieldState<IntRange> field) {
    if (value == null || value.isEmpty) {
      return;
    }
    final range = IntRange(field.value?.start, int.tryParse(value));
    final defaultSliderState = _rangeDefaultSliderKey.currentState;
    final rangeStart = range.start;
    final rangeEnd = range.end;
    if (defaultSliderState != null && rangeStart != null && rangeEnd != null) {
      final sliderValue = defaultSliderState.value;
      final isStartToEnd = rangeStart < rangeEnd;
      final isAboveEnd = isStartToEnd && rangeEnd < sliderValue;
      final isBelowStart = isStartToEnd && sliderValue < rangeStart;
      final isEndToStart = rangeEnd < rangeStart;
      final isBelowEnd = isEndToStart && sliderValue < rangeEnd;
      final isAboveStart = isEndToStart && rangeStart < sliderValue;
      if (isAboveEnd || isBelowEnd) {
        defaultSliderState.didChange(rangeEnd.toDouble());
      } else if (isBelowStart || isAboveStart) {
        defaultSliderState.didChange(rangeStart.toDouble());
      }
    }
    field.didChange(range);
  }

  Widget _rangeField() => FormBuilderField<IntRange>(
        name: "range",
        initialValue: widget.data.isUneven ? null : _rangeInitialValue,
        builder: (FormFieldState<IntRange> field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          child: Column(
            children: [
              FormBuilderTextField(
                name: "range_start",
                initialValue: widget.data.isUneven ? null : "${_rangeInitialValue.start}",
                keyboardType: TextInputType.number,
                onChanged: (value) => _rangeStartChanged(value, field),
                validator: _numberValidator,
              ),
              FormBuilderTextField(
                name: "range_end",
                initialValue: widget.data.isUneven ? null : "${_rangeInitialValue.end}",
                keyboardType: TextInputType.number,
                onChanged: (value) => _rangeEndChanged(value, field),
                validator: _numberValidator,
              ),
              if (field.value.flatMap((value) => value.validate()) ?? false)
                FormBuilderSlider(
                  key: _rangeDefaultSliderKey,
                  name: "range_default",
                  initialValue: field.value!.toScale()[widget.data.defaultIndex].toDouble(),
                  min: min(field.value!.start!, field.value!.end!).toDouble(),
                  max: max(field.value!.start!, field.value!.end!).toDouble(),
                  divisions: (field.value!.start! - field.value!.end!).abs(),
                  valueTransformer: (value) => value.flatMap((value) => value.toInt()),
                  onSaved: (value) {
                    final scale = field.value!.toScale();
                    widget.data.defaultIndex = scale.indexWhere((element) => element == value);
                  },
                ),
            ],
          ),
        ),
        validator: _rangeValidator,
        onSaved: (value) => widget.data.scale = value!.toScale(),
      );

  Widget _scaleField() => FormBuilderField<GlobalKey>(
        name: "scale",
        initialValue: _defaultIndexKey,
        builder: (FormFieldState field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          child: Column(children: [
            for (var entry in _keyedScale) _scaleTextField(entry: entry, superField: field),
          ]),
        ),
        validator: (value) => _scaleValidator(value, scale: _keyedScale),
        onSaved: (key) {
          widget.data.scale = _keyedScale.compactMap((e) => e.value).toList();
          widget.data.defaultIndex = _keyedScale.indexWhere((element) => element.checkKey == key);
        },
      );

  Widget _scaleTextField({required KeyedEntry entry, required FormFieldState superField}) => FormBuilderField(
        key: entry.mainKey,
        name: "scale_field_${entry.mainKey}",
        builder: (FormFieldState field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          child: Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  key: entry.textKey,
                  focusNode: entry.focusNode,
                  name: "scale_textfield_${entry.textKey}",
                  initialValue: entry.value.flatMap((value) => "$value"),
                  keyboardType: TextInputType.number,
                  validator: (value) => _numberValidator(value, isRequired: false),
                  onChanged: (value) => _updateTempScale(value, entry, superField),
                  onTap: _cleanTempScale,
                ),
              ),
              if (entry.value != null)
                Expanded(
                  child: FormBuilderChoiceChip<String>(
                    key: entry.checkKey,
                    name: "scale_checkbox_${entry.checkKey}",
                    options: const [_defaultEntryOption],
                    initialValue: superField.value == entry.checkKey ? _defaultEntryOption.value : null,
                    onChanged: (value) {
                      if (value != null) {
                        superField.value?.currentState?.didChange(null);
                        superField.didChange(entry.checkKey);
                      } else {
                        superField.didChange(null);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: "title",
                initialValue: widget.data.name,
                onSaved: (value) => widget.data.name = value ?? "",
              ),
              FormBuilderCheckboxGroup<String>(
                name: "death",
                initialValue: _DeathOptions.initialValue(left: widget.data.isLeftDeath, right: widget.data.isRightDeath),
                options: [
                  _DeathOptions.left.option,
                  _DeathOptions.right.option,
                ],
                onSaved: (value) {
                  widget.data.isLeftDeath = value!.contains(_DeathOptions.left.label);
                  widget.data.isRightDeath = value.contains(_DeathOptions.right.label);
                },
              ),
              FormBuilderRadioGroup<String>(
                  name: "type",
                  initialValue: _EvennessOptions.fromData(isUneven: _isUneven).label,
                  onChanged: (value) {
                    setState(() {
                      _isUneven = _EvennessOptions.isUneven(value: value);
                    });
                  },
                  onSaved: (value) => widget.data.isUneven = _EvennessOptions.isUneven(value: value),
                  options: [
                    _EvennessOptions.range.option,
                    _EvennessOptions.scale.option,
                  ]),
              if (_isUneven) _scaleField() else _rangeField()
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _validateSaveAndDismiss(context),
          child: const Text("Save"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

class IntRange {
  int? start;
  int? end;

  IntRange(this.start, this.end);

  factory IntRange.from({required List<int> scale}) => IntRange(scale.first, scale.last);

  bool validate() {
    final start = this.start;
    final end = this.end;
    if (start != null && end != null) {
      return (start - end).abs() > 0;
    } else {
      return false;
    }
  }

  List<int> toScale() {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) {
      return [];
    }
    if (start < end) {
      return [for (var i = start; i <= end; i++) i];
    } else {
      return [for (var i = start; i >= end; i--) i];
    }
  }
}

enum _EvennessOptions {
  range,
  scale;

  factory _EvennessOptions.fromData({required bool isUneven}) {
    return isUneven ? _EvennessOptions.scale : _EvennessOptions.range;
  }

  String get label {
    switch (this) {
      case _EvennessOptions.range:
        return "Range";
      case _EvennessOptions.scale:
        return "Scale";
    }
  }

  static bool isUneven({required String? value}) {
    return value == _EvennessOptions.scale.label;
  }

  get option => FormBuilderFieldOption<String>(value: label);
}

enum _DeathOptions {
  left,
  right;

  static List<String> initialValue({required bool left, required bool right}) {
    final leftOption = left ? _DeathOptions.left : null;
    final rightOption = right ? _DeathOptions.right : null;
    return [leftOption, rightOption].compactMap((element) => element?.label).toList();
  }

  String get label {
    switch (this) {
      case _DeathOptions.left:
        return "Left causes death";
      case _DeathOptions.right:
        return "Right causes death";
    }
  }

  get option => FormBuilderChipOption<String>(value: label);
}

class KeyedEntry {
  final mainKey = GlobalKey();
  final textKey = GlobalKey<FormBuilderFieldState>();
  final checkKey = GlobalKey<FormBuilderFieldState>();
  final focusNode = FocusNode();
  int? value;

  KeyedEntry({required this.value});
}
