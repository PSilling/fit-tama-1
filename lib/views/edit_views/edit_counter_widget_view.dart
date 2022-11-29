import 'dart:async';
import 'dart:math';

import 'package:board_aid/util/measure_size.dart';
import 'package:board_aid/util/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../util/extensions.dart';
import '../../widgets/counter_widget/counter_widget.dart';
import '../../widgets/counter_widget/counter_widget_data.dart';
import '../../widgets/dialog_select_input.dart';

class EditCounterWidgetView extends StatefulWidget {
  final CounterWidgetData data;
  final void Function(CounterWidgetData) setData;
  final int width;

  const EditCounterWidgetView({
    super.key,
    required this.data,
    required this.setData,
    required this.width,
  });

  @override
  State<StatefulWidget> createState() => _EditCounterWidgetViewState();
}

class _EditCounterWidgetViewState extends State<EditCounterWidgetView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<CounterWidgetState> _previewKey = GlobalKey<CounterWidgetState>();

  late bool _isUneven;
  late List<KeyedEntry> _keyedScale;
  late final GlobalKey? _defaultIndexKey;
  GlobalKey? _hiddenCurrentIndexKey;
  bool _isReordering = false;

  final _controller = ScrollController();
  final _scaleListEntryHeight = ValueNotifier<double?>(null);
  late final _rangeInitialValue = IntRange.from(scale: widget.data.scale);
  final _rangeDefaultSliderKey = GlobalKey<FormBuilderFieldState>();

  @override
  void initState() {
    _isUneven = widget.data.isUneven;
    if (widget.data.isUneven) {
      final defaultScale = widget.data.scale
          .map((element) => KeyedEntry(value: element))
          .toList();
      _keyedScale = defaultScale + [KeyedEntry(value: null)];
      _defaultIndexKey = defaultScale[widget.data.defaultIndex].checkKey;
    } else {
      _keyedScale = [KeyedEntry(value: null)];
      _defaultIndexKey = null;
    }
  }

  void _onEditComplete(){
    _validateAndSave();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
  }

  /// Handles navigator pop and dice widget data saving on back button press.
  Future<bool> _onWillPop() {
    _validateAndSave();
    return Future.value(true);
  }

  FormBuilderChipOption<String> _defaultEntryOption(BuildContext context) {
    return FormBuilderChipOption<String>(
      value: "Start",
      child: Text(
        "Start",
        style: TextStyle(
          color: ThemeHelper.dialogBackground(context),
        ),
      ),
    );
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

  String? _validateScaleAndScrollToError(Key? key,
      {required List<KeyedEntry> scale}) {
    final error = _scaleValidator(key, scale: _keyedScale);
    if (error != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      });
    }
    return error;
  }

  /// Validates form inputs and saves if possible.
  void _validateAndSave() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      widget.setData(widget.data);
      _previewKey.currentState!.resetIndex();
    }
  }

  void _cleanTempScale() {
    final newState = _keyedScale.compactMap((element) =>
        (element == _keyedScale.last || element.value != null)
            ? element
            : null);
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
    _keyedScale
        .firstWhere((element) => element.textKey == entry.textKey)
        .value = newValue;
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
      return range
              .toScale()
              .elementAtOrNull(widget.data.defaultIndex)
              ?.toDouble() ??
          range.start!.toDouble();
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
          decoration: InputDecoration(
              errorText: field.errorText, border: InputBorder.none),
          child: Column(
            children: [
              Padding(
                padding: ThemeHelper.formPadding(),
                child: FormBuilderTextField(
                  style: TextStyle(
                    color: ThemeHelper.dialogForeground(context),
                  ),
                  cursorColor: ThemeHelper.dialogForeground(context),
                  name: "range_start",
                  decoration: ThemeHelper.dialogInputDecoration(
                    context,
                    label: "Left value",
                  ),
                  initialValue: widget.data.isUneven
                      ? null
                      : "${_rangeInitialValue.start}",
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => _rangeStartChanged(value, field),
                  validator: _numberValidator,
                  onEditingComplete: _onEditComplete,
                ),
              ),
              Padding(
                padding: ThemeHelper.formPadding(),
                child: FormBuilderTextField(
                  style: TextStyle(
                    color: ThemeHelper.dialogForeground(context),
                  ),
                  cursorColor: ThemeHelper.dialogForeground(context),
                  name: "range_end",
                  decoration: ThemeHelper.dialogInputDecoration(
                    context,
                    label: "Right value",
                  ),
                  initialValue:
                      widget.data.isUneven ? null : "${_rangeInitialValue.end}",
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => _rangeEndChanged(value, field),
                  validator: _numberValidator,
                  onEditingComplete: _onEditComplete,
                ),
              ),
              if (field.value.flatMap((value) => value.validate()) ?? false)
                Padding(
                  padding: ThemeHelper.formPadding(),
                  child: FormBuilderSlider(
                    activeColor: ThemeHelper.dialogForeground(context),
                    inactiveColor:
                        ThemeHelper.dialogForeground(context).withOpacity(0.25),
                    textStyle: TextStyle(
                      color: ThemeHelper.dialogForeground(context),
                    ),
                    decoration: ThemeHelper.dialogInputDecoration(context,
                        label: "Starting value"),
                    key: _rangeDefaultSliderKey,
                    name: "range_default",
                    initialValue: _defaultSliderInitialValue(field: field),
                    min: min(field.value!.start!, field.value!.end!).toDouble(),
                    max: max(field.value!.start!, field.value!.end!).toDouble(),
                    divisions: (field.value!.start! - field.value!.end!).abs(),
                    valueTransformer: (value) =>
                        value.flatMap((value) => value.toInt()),
                    onSaved: (value) {
                      final scale = field.value!.toScale();
                      widget.data.defaultIndex =
                          scale.indexWhere((element) => element == value);
                    },
                    onChanged: (value) {
                      _validateAndSave();
                      setState(() {});
                    },
                  ),
                ),
            ],
          ),
        ),
        validator: _rangeValidator,
        onSaved: (value) => widget.data.scale = value!.toScale(),
      );

  Widget _scaleField(BuildContext context) => Padding(
        padding: ThemeHelper.formPadding(),
        child: FormBuilderField<GlobalKey>(
          name: "scale",
          initialValue: _defaultIndexKey,
          builder: (FormFieldState field) => InputDecorator(
            decoration: ThemeHelper.dialogInputDecoration(context,
                errorText: field.errorText,
                label: "Values",
                hasBorder: false,
                isDense: true),
            child: Column(
              children: [
                // HACK: Just because it's in Dialog
                ValueListenableBuilder(
                  valueListenable: _scaleListEntryHeight,
                  builder: (context, height, child) {
                    if (height == null) {
                      return const SizedBox(width: double.maxFinite, height: 0);
                    }
                    return SizedBox(
                      height: (_keyedScale.length - 1) * height,
                      width: double.maxFinite,
                      child: ReorderableListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorderEnd: (index) => _isReordering = false,
                        onReorderStart: (index) => _isReordering = true,
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) newIndex--;

                            final entry = _keyedScale.removeAt(oldIndex);
                            _keyedScale.insert(newIndex, entry);
                          });
                        },
                        itemCount: _keyedScale.length - 1,
                        itemBuilder: (context, index) {
                          final entry = _keyedScale[index];
                          return Dismissible(
                            key: entry.listKey,
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Theme.of(context).colorScheme.error,
                              alignment: AlignmentDirectional.centerEnd,
                              child: const Text("Remove"),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                _keyedScale.removeAt(index);
                              });
                            },
                            onUpdate: (details) {
                              _validateAndSave();
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: _scaleTextField(
                                    context,
                                    entry: entry,
                                    superField: field,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 5,
                                  ),
                                  child: Icon(
                                    Icons.drag_handle,
                                    color:
                                        ThemeHelper.dialogForeground(context),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                MeasureSize(
                  onChange: (size) => _scaleListEntryHeight.value = size.height,
                  child: _scaleTextField(context,
                      entry: _keyedScale.last, superField: field),
                ),
              ],
            ),
          ),
          validator: (value) =>
              _validateScaleAndScrollToError(value, scale: _keyedScale),
          onSaved: (key) {
            widget.data.scale = _keyedScale.compactMap((e) => e.value).toList();
            widget.data.defaultIndex =
                _keyedScale.indexWhere((element) => element.checkKey == key);
          },
        ),
      );

  Widget _scaleTextField(
    BuildContext context, {
    required KeyedEntry entry,
    required FormFieldState superField,
  }) =>
      FormBuilderField(
        key: entry.fieldKey,
        name: "scale_field_${entry.fieldKey}",
        builder: (FormFieldState field) => InputDecorator(
          decoration: ThemeHelper.dialogInputDecoration(context,
              errorText: field.errorText,
              hasBorder: false,
              isDense: true,
              hasPadding: false),
          child: Row(
            children: [
              if (entry.value != null)
                SizedBox(
                  width: 70,
                  child: FormBuilderChoiceChip<String>(
                    backgroundColor:
                        ThemeHelper.dialogForeground(context).withOpacity(0.5),
                    selectedColor: ThemeHelper.dialogForeground(context),
                    key: entry.checkKey,
                    decoration: ThemeHelper.dialogInputDecoration(context,
                        hasBorder: false, isDense: true, hasPadding: false),
                    name: "scale_checkbox_${entry.checkKey}",
                    options: [_defaultEntryOption(context)],
                    initialValue: superField.value == entry.checkKey
                        ? _defaultEntryOption(context).value
                        : null,
                    alignment: WrapAlignment.start,
                    onChanged: (value) {
                      if (value != null) {
                        superField.value?.currentState?.didChange(null);
                        superField.didChange(entry.checkKey);
                      } else {
                        superField.didChange(null);
                      }
                      _validateAndSave();
                      setState(() {});
                    },
                  ),
                ),
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    if (_isReordering)
                      Text(
                        "${entry.textKey.currentState?.value ?? ""}",
                        style: ThemeHelper.textFieldStyle(context),
                      ),
                    Opacity(
                      // It cannot be removed when reordering, otherwise the keyboard will disappear
                      // It cannot stay visible, because it causes exception with layers
                      opacity: _isReordering ? 0 : 1,
                      child: FormBuilderTextField(
                        key: entry.textKey,
                        focusNode: entry.focusNode,
                        style: ThemeHelper.textFieldStyle(context),
                        cursorColor: ThemeHelper.textFieldCursorColor(context),
                        decoration: ThemeHelper.dialogInputDecoration(context),
                        name: "scale_textfield_${entry.textKey}",
                        initialValue: entry.value.flatMap((value) => "$value"),
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        validator: (value) =>
                            _numberValidator(value, isRequired: false),
                        onChanged: (value) =>
                            _updateTempScale(value, entry, superField),
                        onTap: _cleanTempScale,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          final index = _keyedScale.indexOf(entry);
                          final nextEntry =
                              _keyedScale.elementAtOrNull(index + 1);
                          if (nextEntry == null) {
                            return;
                          }
                          FocusScope.of(context)
                              .requestFocus(nextEntry.focusNode);
                          _validateAndSave();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final widthDivisor = widget.width == 1 ? 2 : 1;
    final heightDivisor = widget.width == 1 ? 1 : 2;
    final previewWidth = MediaQuery.of(context).size.width / widthDivisor -
        2 * ThemeHelper.cardSpacing();
    final previewHeight = previewWidth / heightDivisor;
    final iconSize = (Theme.of(context).iconTheme.size ?? 24) *
        ThemeHelper.largeIconSizeModifier;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ThemeHelper.editViewBackground(context),
        appBar: AppBar(
          title: const Text('Customize Widget'),
        ),
        body: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.vertical,
          child: FormBuilder(
            key: _formKey,
            child: Padding(
              padding: ThemeHelper.editViewPadding(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: ThemeHelper.subtitleFontSize,
                        color: ThemeHelper.editViewForeground(context),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: CounterWidget(
                        key: _previewKey,
                        initData: widget.data,
                        startEditing: false,
                        width: widget.width,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Divider(
                      color: ThemeHelper.editViewForeground(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: ThemeHelper.subtitleFontSize,
                        color: ThemeHelper.editViewForeground(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderTextField(
                      style: TextStyle(
                        color: ThemeHelper.dialogForeground(context),
                      ),
                      cursorColor: ThemeHelper.dialogForeground(context),
                      name: "title",
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Title"),
                      textInputAction: TextInputAction.done,
                      initialValue: widget.data.name,
                      onSaved: (value) => widget.data.name = value ?? "",
                      onEditingComplete: _onEditComplete,
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: DialogSelectInput(
                      value: widget.data.backgroundColor,
                      defaultValue: ThemeHelper.cardBackgroundColor(context),
                      onSelected: (color) => setState(() {
                        widget.data.backgroundColor = color;
                      }),
                      itemLabelMap: ThemeHelper.cardBackgroundColors,
                      itemBuilder: (item) => Icon(
                        Icons.circle,
                        color: item,
                        size: iconSize * 1.8, // larger for easier selection
                      ),
                      label: 'Color',
                      dialogTitle: 'Pick a Color',
                      iconCode: Icons.circle.codePoint,
                      iconColor: widget.data.backgroundColor ??
                          ThemeHelper.cardBackgroundColor(context),
                      iconSize: iconSize,
                      heightDivisor: 3.0,
                      itemsPerRow: 4,
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderFilterChip<String>(
                      name: "death",
                      checkmarkColor: ThemeHelper.dialogBackground(context),
                      backgroundColor: ThemeHelper.dialogForeground(context)
                          .withOpacity(0.5),
                      selectedColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "End on a death icon"),
                      spacing: ThemeHelper.dialogChipSpacing,
                      initialValue: _DeathOptions.initialValue(
                          left: widget.data.isLeftDeath,
                          right: widget.data.isRightDeath),
                      options: [
                        _DeathOptions.left.getOption(context),
                        _DeathOptions.right.getOption(context),
                      ],
                      onSaved: (value) {
                        widget.data.isLeftDeath =
                            value!.contains(_DeathOptions.left.label);
                        widget.data.isRightDeath =
                            value.contains(_DeathOptions.right.label);
                      },
                      onChanged: (value) {
                        _validateAndSave();
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderRadioGroup<String>(
                      activeColor: ThemeHelper.dialogForeground(context),
                      decoration: ThemeHelper.dialogInputDecoration(context,
                          label: "Scale"),
                      name: "type",
                      initialValue:
                          _EvennessOptions.fromData(isUneven: _isUneven).label,
                      onChanged: (value) {
                        _isUneven = _EvennessOptions.isUneven(value: value);
                        _validateAndSave();
                        setState(() {});
                      },
                      onSaved: (value) => widget.data.isUneven =
                          _EvennessOptions.isUneven(value: value),
                      options: [
                        _EvennessOptions.range.getOption(context),
                        _EvennessOptions.scale.getOption(context),
                      ],
                    ),
                  ),
                  if (_isUneven) _scaleField(context) else _rangeField(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
          color: ThemeHelper.dialogForeground(context),
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
    return [leftOption, rightOption]
        .compactMap((element) => element?.label)
        .toList();
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
          color: ThemeHelper.dialogBackground(context),
        ),
      ),
    );
  }
}

class KeyedEntry {
  final fieldKey = GlobalKey();
  final listKey = GlobalKey();
  final textKey = GlobalKey<FormBuilderFieldState>();
  final checkKey = GlobalKey<FormBuilderFieldState>();
  final focusNode = FocusNode();
  int? value;

  KeyedEntry({required this.value});
}
