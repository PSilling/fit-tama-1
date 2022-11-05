import 'package:flutter/material.dart';

/// PresetsView search text field accompanied by control buttons.
class PresetsSearchInput extends StatelessWidget {
  const PresetsSearchInput({
    super.key,
    required this.onSearchChanged,
    required this.onCancel,
  });

  final Function(String searched) onSearchChanged;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.search),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search presets…',
                hintStyle: Theme.of(context).textTheme.titleMedium,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground
                  ),
                ),
                // TODO: maybe disable underline when focused?
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              style: Theme.of(context).textTheme.titleMedium,
              cursorColor: Theme.of(context).colorScheme.onBackground,
              onChanged: onSearchChanged,
            ),
          ),
        ),
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.clear),
        ),
      ],
    );
  }
}
