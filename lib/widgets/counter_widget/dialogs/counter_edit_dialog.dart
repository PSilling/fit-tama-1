import 'dart:math';

import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../util/extensions.dart';
import '../counter_widget_data.dart';

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

  final _controller = ScrollController();
  late final _rangeInitialValue = IntRange.from(scale: widget.data.scale);
  final _rangeDefaultSliderKey = GlobalKey<FormBuilderFieldState>();
  static const _defaultEntryOption = FormBuilderChipOption<String>(value: "Start");

  @override
  void initState() {
    _isUneven = widget.data.isUneven;
    if (widget.data.isUneven) {
      final defaultScale = widget.data.scale.map((element) => KeyedEntry(value: element)).toList();
      _keyedScale = defaultScale + [KeyedEntry(value: null)];
      _defaultIndexKey = defaultScale[widget.data.defaultIndex].checkKey;
    } else {
      _keyedScale = [KeyedEntry(value: null)];
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
      return "Scale cannot be empty";
    } else if (key == null) {
      return "You have to choose a default value";
    } else {
      return null;
    }
  }

  String? _validateScaleAndScrollToError(Key? key, {required List<KeyedEntry> scale}) {
    final error = _scaleValidator(key, scale: _keyedScale);
    if (error != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      });
    }
    return error;
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

  double _defaultSliderInitialValue({required FormFieldState<IntRange> field}) {
    final range = field.value!;
    final defaultSliderStateValue = _rangeDefaultSliderKey.currentState?.value;
    if (defaultSliderStateValue != null) {
      if (range.toScale().contains(defaultSliderStateValue)) {
        return defaultSliderStateValue;
      } else {
        return range.start!.toDouble();
      }
    } else {
      return range.toScale().elementAtOrNull(widget.data.defaultIndex)?.toDouble() ?? range.start!.toDouble();
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
      final sliderValue = defaultSliderState.value.toInt();
      switch (range.juxtapose(value: sliderValue)!) {
        case RangeJuxtaposition.outsideStart:
          defaultSliderState.didChange(rangeStart.toDouble());
          break;
        case RangeJuxtaposition.outsideEnd:
          defaultSliderState.didChange(rangeEnd.toDouble());
          break;
        case RangeJuxtaposition.inside:
          break;
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
      final sliderValue = defaultSliderState.value.toInt();
      switch (range.juxtapose(value: sliderValue)!) {
        case RangeJuxtaposition.outsideStart:
          defaultSliderState.didChange(rangeStart.toDouble());
          break;
        case RangeJuxtaposition.outsideEnd:
          defaultSliderState.didChange(rangeEnd.toDouble());
          break;
        case RangeJuxtaposition.inside:
          break;
      }
    }
    field.didChange(range);
  }

  Widget _rangeField(BuildContext context) => FormBuilderField<IntRange>(
        name: "range",
        initialValue: widget.data.isUneven ? null : _rangeInitialValue,
        builder: (FormFieldState<IntRange> field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText, border: InputBorder.none),
          child: Column(
            children: [
              FormBuilderTextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                cursorColor: Theme.of(context).colorScheme.onSurface,
                name: "range_start",
                decoration: ThemeHelper.formInputDecoration(context, label: "Left value"),
                initialValue: widget.data.isUneven ? null : "${_rangeInitialValue.start}",
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                onChanged: (value) => _rangeStartChanged(value, field),
                validator: _numberValidator,
              ),
              FormBuilderTextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                cursorColor: Theme.of(context).colorScheme.onSurface,
                name: "range_end",
                decoration: ThemeHelper.formInputDecoration(context, label: "Right value"),
                initialValue: widget.data.isUneven ? null : "${_rangeInitialValue.end}",
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                onChanged: (value) => _rangeEndChanged(value, field),
                validator: _numberValidator,
              ),
              if (field.value.flatMap((value) => value.validate()) ?? false)
                FormBuilderSlider(
                  activeColor: Theme.of(context).colorScheme.onSurface,
                  inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: ThemeHelper.formInputDecoration(context, label: "Starting value"),
                  key: _rangeDefaultSliderKey,
                  name: "range_default",
                  initialValue: _defaultSliderInitialValue(field: field),
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

  Widget _scaleField(BuildContext context) => FormBuilderField<GlobalKey>(
        name: "scale",
        initialValue: _defaultIndexKey,
        builder: (FormFieldState field) => InputDecorator(
          decoration: ThemeHelper.formInputDecoration(context,
              errorText: field.errorText, label: "Values", hasBorder: false, isDense: true),
          child: Column(children: [
            for (var entry in _keyedScale) _scaleTextField(context, entry: entry, superField: field),
          ]),
        ),
        validator: (value) => _validateScaleAndScrollToError(value, scale: _keyedScale),
        onSaved: (key) {
          widget.data.scale = _keyedScale.compactMap((e) => e.value).toList();
          widget.data.defaultIndex = _keyedScale.indexWhere((element) => element.checkKey == key);
        },
      );

  Widget _scaleTextField(BuildContext context, {required KeyedEntry entry, required FormFieldState superField}) =>
      FormBuilderField(
        key: entry.mainKey,
        name: "scale_field_${entry.mainKey}",
        builder: (FormFieldState field) => InputDecorator(
          decoration: ThemeHelper.formInputDecoration(context,
              errorText: field.errorText, hasBorder: false, isDense: true, hasPadding: false),
          child: Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  key: entry.textKey,
                  focusNode: entry.focusNode,
                  style: ThemeHelper.textFieldStyle(context),
                  cursorColor: ThemeHelper.textFieldCursorColor(context),
                  decoration: ThemeHelper.formInputDecoration(context),
                  name: "scale_textfield_${entry.textKey}",
                  initialValue: entry.value.flatMap((value) => "$value"),
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  validator: (value) => _numberValidator(value, isRequired: false),
                  onChanged: (value) => _updateTempScale(value, entry, superField),
                  onTap: _cleanTempScale,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    final index = _keyedScale.indexOf(entry);
                    final nextEntry = _keyedScale.elementAtOrNull(index + 1);
                    if (nextEntry == null) {
                      return;
                    }
                    FocusScope.of(context).requestFocus(nextEntry.focusNode);
                  },
                ),
              ),
              if (entry.value != null)
                SizedBox(
                  width: 80,
                  child: FormBuilderChoiceChip<String>(
                    key: entry.checkKey,
                    decoration: ThemeHelper.formInputDecoration(context, hasBorder: false, isDense: true, hasPadding: false),
                    name: "scale_checkbox_${entry.checkKey}",
                    options: const [_defaultEntryOption],
                    initialValue: superField.value == entry.checkKey ? _defaultEntryOption.value : null,
                    alignment: WrapAlignment.end,
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
      backgroundColor: Theme.of(context).colorScheme.background,
      content: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.vertical,
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                cursorColor: Theme.of(context).colorScheme.onSurface,
                name: "title",
                decoration: ThemeHelper.formInputDecoration(context, label: "Title"),
                initialValue: widget.data.name,
                onSaved: (value) => widget.data.name = value ?? "",
              ),
              FormBuilderFilterChip<String>(
                name: "death",
                decoration: ThemeHelper.formInputDecoration(context, label: "End on a death icon"),
                spacing: ThemeHelper.widgetDialogChipSpacing,
                initialValue: _DeathOptions.initialValue(left: widget.data.isLeftDeath, right: widget.data.isRightDeath),
                options: [
                  _DeathOptions.left.getOption(context),
                  _DeathOptions.right.getOption(context),
                ],
                onSaved: (value) {
                  widget.data.isLeftDeath = value!.contains(_DeathOptions.left.label);
                  widget.data.isRightDeath = value.contains(_DeathOptions.right.label);
                },
              ),
              FormBuilderRadioGroup<String>(
                  activeColor: Theme.of(context).colorScheme.onBackground,
                  decoration: ThemeHelper.formInputDecoration(context, label: "Scale"),
                  name: "type",
                  initialValue: _EvennessOptions.fromData(isUneven: _isUneven).label,
                  onChanged: (value) {
                    setState(() {
                      _isUneven = _EvennessOptions.isUneven(value: value);
                    });
                  },
                  onSaved: (value) => widget.data.isUneven = _EvennessOptions.isUneven(value: value),
                  options: [
                    _EvennessOptions.range.getOption(context),
                    _EvennessOptions.scale.getOption(context),
                  ]),
              if (_isUneven) _scaleField(context) else _rangeField(context)
            ],
          ),
        ),
      ),
      actions: [
        ThemeHelper.buttonPrimary(
          context: context,
          onPressed: () => _validateSaveAndDismiss(context),
          label: "Save",
        ),
        ThemeHelper.buttonSecondary(
          context: context,
          onPressed: () => Navigator.of(context).pop(),
          label: "Cancel",
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

  RangeJuxtaposition? juxtapose({required int value}) {
    final start = this.start;
    final end = this.end;
    if (start == null || end == null) {
      return null;
    }
    final isStartToEnd = start < end;
    final isAboveEnd = isStartToEnd && end < value;
    final isBelowStart = isStartToEnd && value < start;
    final isEndToStart = end < start;
    final isBelowEnd = isEndToStart && value < end;
    final isAboveStart = isEndToStart && start < value;
    if (isBelowStart || isAboveStart) {
      return RangeJuxtaposition.outsideStart;
    } else if (isBelowEnd || isAboveEnd) {
      return RangeJuxtaposition.outsideEnd;
    } else {
      return RangeJuxtaposition.inside;
    }
  }
}

enum RangeJuxtaposition {
  outsideStart,
  outsideEnd,
  inside;
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
        return "Custom";
    }
  }

  static bool isUneven({required String? value}) {
    return value == _EvennessOptions.scale.label;
  }

  FormBuilderFieldOption<String> getOption(BuildContext context) {
    return FormBuilderFieldOption<String>(
      value: label,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
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
        return "Left side";
      case _DeathOptions.right:
        return "Right side";
    }
  }

  FormBuilderChipOption<String> getOption(BuildContext context) {
    return FormBuilderChipOption<String>(
      value: label,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class KeyedEntry {
  final mainKey = GlobalKey();
  final textKey = GlobalKey<FormBuilderFieldState>();
  final checkKey = GlobalKey<FormBuilderFieldState>();
  final focusNode = FocusNode();
  int? value;

  KeyedEntry({required this.value});
}
