import 'dart:async';

import 'package:board_aid/models/preset_model.dart';
import 'package:board_aid/views/presets_view/card/preset_card.dart';
import 'package:board_aid/widgets/dialog_select_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../util/themes.dart';
import '../../util/icons.dart';

/// Preset card customization view.
class CustomizePresetView extends StatefulWidget {
  const CustomizePresetView({
    super.key,
    required this.preset,
    required this.onSave,
  });

  final PresetModel preset;
  final Function(PresetModel preset) onSave;

  @override
  State<CustomizePresetView> createState() => _CustomizePresetViewState();
}

class _CustomizePresetViewState extends State<CustomizePresetView> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Timer _updateTimer;

  /// Handles navigator pop and preset saving on back button press.
  Future<bool> _onWillPop(context) {
    _validateAndSave();
    return Future.value(true);
  }

  /// Validates name input value.
  String? _nameValidator(String? name) {
    if (name == null || name == '') {
      return 'Preset name cannot be empty';
    }
    return null;
  }

  /// Validates form inputs and saves if possible.
  void _validateAndSave() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      widget.preset.defaultTitle = false;
      widget.onSave(widget.preset);
    }
  }

  @override
  void initState() {
    super.initState();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        setState(() {
          _validateAndSave();
        });
      },
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetCardWidth =
        MediaQuery.of(context).size.width / 2 - 2 * ThemeHelper.cardSpacing();
    final presetCardHeight = presetCardWidth * 2 / 3;
    final iconSize = (Theme.of(context).iconTheme.size ?? 24) *
        ThemeHelper.largeIconSizeModifier;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: ThemeHelper.editViewBackground(context),
        appBar: AppBar(
          title: const Text('Customize Preset'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: ThemeHelper.editViewPadding(),
            child: FormBuilder(
              key: _formKey,
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
                      width: presetCardWidth,
                      height: presetCardHeight,
                      child: PresetCard(
                        preset: widget.preset,
                        enabled: false,
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
                      name: 'name',
                      style: TextStyle(
                        color: ThemeHelper.editViewForeground(context),
                      ),
                      cursorColor: ThemeHelper.editViewForeground(context),
                      decoration: ThemeHelper.editViewInputDecoration(
                        context,
                        label: 'Preset name',
                      ),
                      initialValue: widget.preset.name,
                      validator: _nameValidator,
                      onSaved: (value) => widget.preset.name = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: FormBuilderTextField(
                      name: 'game',
                      style: TextStyle(
                        color: ThemeHelper.editViewForeground(context),
                      ),
                      cursorColor: ThemeHelper.editViewForeground(context),
                      decoration: ThemeHelper.editViewInputDecoration(
                        context,
                        label: 'Game title',
                      ),
                      initialValue: widget.preset.game,
                      onSaved: (value) => widget.preset.game = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: DialogSelectInput(
                      value: widget.preset.iconCode,
                      onSelected: (iconCode) => setState(() {
                        widget.preset.iconCode = iconCode;
                      }),
                      itemLabelMap: ThemeHelper.presetIconCodes,
                      itemBuilder: (item) => iconFromCode(
                        iconCode: item,
                        color: ThemeHelper.dialogForeground(context),
                        size: iconSize,
                      ),
                      label: 'Icon',
                      dialogTitle: 'Pick an Icon',
                      iconCode: widget.preset.iconCode,
                      iconColor: ThemeHelper.editViewForeground(context),
                      iconSize: iconSize,
                      heightDivisor: 2,
                      itemsPerRow: 6,
                    ),
                  ),
                  Padding(
                    padding: ThemeHelper.formPadding(),
                    child: DialogSelectInput(
                      value: widget.preset.backgroundColor,
                      onSelected: (color) => setState(() {
                        widget.preset.backgroundColor = color;
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
                      iconColor: widget.preset.backgroundColor,
                      iconSize: iconSize,
                      heightDivisor: 4.0,
                      itemsPerRow: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
