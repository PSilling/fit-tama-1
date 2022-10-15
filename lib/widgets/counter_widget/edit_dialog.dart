import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tabletop_assistant/widgets/counter_widget/counter_widget.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tabletop_assistant/helpers.dart';

class EditDialog extends StatefulWidget {
  final CounterWidgetData data;
  final void Function(CounterWidgetData) setData;

  const EditDialog({super.key, required this.data, required this.setData});

  @override
  State<StatefulWidget> createState() => EditDialogState();
}

class EditDialogState extends State<EditDialog> {
  final formKey = GlobalKey<FormBuilderState>();

  late bool isUneven;
  late List<KeyedEntry> keyedScale;
  late final GlobalKey? defaultIndexKey;
  late final rangeInitialValue = IntRange.from(scale: widget.data.scale);

  @override
  void initState() {
    isUneven = widget.data.isUneven;
    if (widget.data.isUneven) {
      final defaultScale = widget.data.scale
          .map((element) => KeyedEntry(value: element))
          .toList();
      keyedScale = defaultScale + [KeyedEntry(value: null)];
      defaultIndexKey = defaultScale[widget.data.defaultIndex].checkKey;
    } else {
      keyedScale = [];
      defaultIndexKey = null;
    }
    super.initState();
  }

  String? textValidator(String? value) {
    if ((value ?? "").isEmpty) {
      return "Text field cannot be emtpy";
    } else {
      return null;
    }
  }

  String? rangeValidator(IntRange? range) {
    return (range != null) ? null : "Range must be set";
  }

  void validateSaveAndDismiss() {
    final formState = formKey.currentState;
    if (formState == null) {
      return;
    }
    if (formState.validate()) {
      formState.save();
      widget.setData(widget.data);
      Navigator.of(context).pop();
    }
  }

  void cleanTempScale() {
    final newState = keyedScale.compactMap((element) =>
        (element == keyedScale.last || element?.value != null) ? element : null);
    setState(() {
      final focused = FocusScope.of(context).focusedChild;
      if (!newState.map((e) => e.focusNode).contains(focused)) {
        FocusScope.of(context).previousFocus();
      }
      keyedScale = List.from(newState);
    });
  }

  void updateTempScale(String? value, KeyedEntry entry, FormFieldState field) {
    final newValue = value.flatMap((value) => int.tryParse(value));
    keyedScale.firstWhere((element) => element.textKey == entry.textKey).value =
        newValue;
    if (keyedScale.last.textKey == entry.textKey && newValue != null) {
      keyedScale.add(KeyedEntry(value: null));
    }
    if (newValue == null && field.value == entry.checkKey) {
      field.didChange(null);
    }
  }

  void rangeStartChanged(String? value, FormFieldState<IntRange> field) {
    if (value == null || value.isEmpty) {
      return;
    }
    final range = IntRange(int.tryParse(value), field.value?.end);
    final defaultSliderState = rangeDefaultSliderKey.currentState;
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

  void rangeEndChanged(String? value, FormFieldState<IntRange> field) {
    if (value == null || value.isEmpty) {
      return;
    }
    final range = IntRange(field.value?.start, int.tryParse(value));
    final defaultSliderState = rangeDefaultSliderKey.currentState;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FormBuilder(
          key: formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: "title",
                initialValue: widget.data.name,
                validator: textValidator,
                onSaved: (value) => widget.data.name = value!,
              ),
              FormBuilderCheckboxGroup<String>(
                name: "left_death",
                initialValue: (widget.data.isLeftDeath
                        ? <String>["Left causes death"]
                        : <String>[]) +
                    (widget.data.isRightDeath
                        ? <String>["Right causes death"]
                        : <String>[]),
                options: const [
                  FormBuilderFieldOption<String>(value: "Left causes death"),
                  FormBuilderFieldOption<String>(value: "Right causes death"),
                ],
                onSaved: (value) {
                  widget.data.isLeftDeath =
                      value!.contains("Left causes death");
                  widget.data.isRightDeath =
                      value.contains("Right causes death");
                },
              ),
              FormBuilderRadioGroup<String>(
                  name: "type",
                  initialValue: isUneven ? "Scale" : "Range",
                  onChanged: (value) {
                    setState(() {
                      isUneven = value == "Scale";
                    });
                  },
                  onSaved: (value) => widget.data.isUneven = value == "Scale",
                  options: const [
                    FormBuilderFieldOption(value: "Range"),
                    FormBuilderFieldOption(value: "Scale"),
                  ]),
              if (isUneven) scaleField() else rangeField()
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: validateSaveAndDismiss,
          child: const Text("Save"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  final rangeDefaultSliderKey = GlobalKey<FormBuilderFieldState>();

  Widget rangeField() => FormBuilderField<IntRange>(
        name: "range",
        initialValue: widget.data.isUneven ? null : rangeInitialValue,
        builder: (FormFieldState<IntRange> field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          child: Column(
            children: [
              FormBuilderTextField(
                name: "range_start",
                initialValue:
                    widget.data.isUneven ? null : "${rangeInitialValue.start}",
                keyboardType: TextInputType.number,
                onChanged: (value) => rangeStartChanged(value, field),
                validator: textValidator,
              ),
              FormBuilderTextField(
                name: "range_end",
                initialValue:
                    widget.data.isUneven ? null : "${rangeInitialValue.end}",
                keyboardType: TextInputType.number,
                onChanged: (value) => rangeEndChanged(value, field),
                validator: textValidator,
              ),
              if (field.value.flatMap((value) => value.validate()) ?? false)
                FormBuilderSlider(
                  key: rangeDefaultSliderKey,
                  name: "range_default",
                  initialValue: widget.data.isUneven
                      ? field.value!.start!.toDouble()
                      : widget.data.defaultIndex.toDouble(),
                  min: min(field.value!.start!, field.value!.end!).toDouble(),
                  max: max(field.value!.start!, field.value!.end!).toDouble(),
                  divisions: (field.value!.start! - field.value!.end!).abs(),
                  valueTransformer: (value) =>
                      value.flatMap((value) => value.toInt()),
                  onSaved: (value) => widget.data.defaultIndex = value!.toInt(),
                )
            ],
          ),
        ),
        validator: rangeValidator,
        onSaved: (value) => widget.data.scale = value!.toScale(),
      );

  Widget scaleField() => FormBuilderField<GlobalKey>(
        name: "scale",
        initialValue: defaultIndexKey,
        builder: (FormFieldState field) => InputDecorator(
          decoration: InputDecoration(errorText: field.errorText),
          child: Column(children: [
            for (var entry in keyedScale)
              scaleTextField(entry: entry, superField: field),
          ]),
        ),
        validator: (key) {
          final isScaleEmpty =
              keyedScale.every((element) => element.value == null);
          if (isScaleEmpty) {
            return "Scale cannnot be empty";
          } else if (key == null) {
            return "You have to choose a default value";
          } else {
            return null;
          }
        },
        onSaved: (key) {
          widget.data.scale = keyedScale.compactMap((e) => e?.value).toList();
          widget.data.defaultIndex =
              keyedScale.indexWhere((element) => element.checkKey == key);
        },
      );

  Widget scaleTextField(
          {required KeyedEntry entry, required FormFieldState superField}) =>
      FormBuilderField(
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
                  onChanged: (value) =>
                      updateTempScale(value, entry, superField),
                  onTap: cleanTempScale,
                ),
              ),
              if (entry.value != null)
                Expanded(
                  child: FormBuilderChoiceChip<String>(
                    key: entry.checkKey,
                    decoration:
                        const InputDecoration(disabledBorder: InputBorder.none),
                    name: "scale_checkbox_${entry.checkKey}",
                    options: const [
                      FormBuilderChipOption<String>(value: "Default")
                    ],
                    initialValue:
                        defaultIndexKey == entry.checkKey ? "Default" : null,
                    onChanged: (value) {
                      if (value != null) {
                        superField.value?.currentState?.didChange(null);
                      }
                      superField.didChange(entry.checkKey);
                    },
                  ),
                ),
            ],
          ),
        ),
      );
}

class IntRange {
  int? start;
  int? end;

  IntRange(this.start, this.end);

  factory IntRange.from({required List<int> scale}) =>
      IntRange(scale.first, scale.last);

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

class KeyedEntry {
  final mainKey = GlobalKey();
  final textKey = GlobalKey<FormBuilderFieldState>();
  final checkKey = GlobalKey<FormBuilderFieldState>();
  final focusNode = FocusNode();
  int? value;

  KeyedEntry({required this.value});
}
