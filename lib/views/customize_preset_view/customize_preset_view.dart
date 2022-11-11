import 'package:board_aid/models/preset_model.dart';
import 'package:board_aid/views/presets_view/card/preset_card.dart';
import 'package:board_aid/widgets/dialog_select_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../util/themes.dart';
import '../../util/icons.dart';
import 'customize_preset_appbar.dart';

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
  late PresetModel _updatedPreset;

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
  bool _validateAndSave() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      widget.onSave(_updatedPreset);
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _updatedPreset = widget.preset.copy();
  }

  @override
  Widget build(BuildContext context) {
    final presetCardWidth =
        MediaQuery.of(context).size.width / 2 - 2 * ThemeHelper.cardSpacing();
    final presetCardHeight = presetCardWidth * 2 / 3;
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomizePresetAppbar(
          onSave: () {
            if (_validateAndSave()) {
              Navigator.pop(context);
            }
          },
          onRevert: () => setState(() {
            _updatedPreset = widget.preset.copy();
          }),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: presetCardWidth,
                      height: presetCardHeight,
                      child: PresetCard(
                        preset: _updatedPreset,
                        enabled: false,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Expanded(
                      child: Divider(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FormBuilderTextField(
                      name: 'name',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      cursorColor: Theme.of(context).colorScheme.onSurface,
                      decoration: ThemeHelper.formInputDecoration(
                        context,
                        label: 'Preset name',
                      ),
                      initialValue: _updatedPreset.name,
                      validator: _nameValidator,
                      onSaved: (value) => _updatedPreset.name = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FormBuilderTextField(
                      name: 'game',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      cursorColor: Theme.of(context).colorScheme.onSurface,
                      decoration: ThemeHelper.formInputDecoration(
                        context,
                        label: 'Game title',
                      ),
                      initialValue: _updatedPreset.game,
                      onSaved: (value) => _updatedPreset.game = value ?? '',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DialogSelectInput(
                      value: _updatedPreset.iconCode,
                      onSelected: (iconCode) => setState(() {
                        _updatedPreset.iconCode = iconCode;
                      }),
                      itemLabelMap: ThemeHelper.presetIconCodes,
                      itemBuilder: (item) => iconFromCode(
                        iconCode: item,
                        color: ThemeHelper.dialogForeground(context),
                        size: 30,
                      ),
                      label: 'Icon',
                      dialogTitle: 'Pick an icon',
                      iconCode: _updatedPreset.iconCode,
                      iconColor: ThemeHelper.dialogForeground(context),
                      iconSize: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DialogSelectInput(
                      value: _updatedPreset.backgroundColor,
                      onSelected: (color) => setState(() {
                        _updatedPreset.backgroundColor = color;
                      }),
                      itemLabelMap: ThemeHelper.backgroundColors,
                      itemBuilder: (item) => Icon(
                        Icons.circle,
                        color: item,
                        size: 30,
                      ),
                      label: 'Color',
                      dialogTitle: 'Pick a color',
                      iconCode: Icons.circle.codePoint,
                      iconColor: _updatedPreset.backgroundColor,
                      iconSize: 30,
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
