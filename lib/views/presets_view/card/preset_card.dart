import 'package:board_aid/models/preset_model.dart';
import 'package:board_aid/util/icons.dart';
import 'package:board_aid/util/themes.dart';
import 'package:board_aid/views/presets_view/card/preset_card_more_button.dart';
import 'package:flutter/material.dart';

/// Card containing basic information about a Preset.
class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.preset,
    this.onFavouritePressed,
    this.onMoreSelected,
    this.enabled = true,
  });

  final PresetModel preset;
  final Function()? onFavouritePressed;
  final Function(PresetCardMoreOption option)? onMoreSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ThemeHelper.cardElevation(),
      color: preset.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeHelper.borderRadius()),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: iconFromCode(
                    iconCode: preset.iconCode,
                    color: ThemeHelper.cardForegroundColor(context),
                    size: 30,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: ThemeHelper.cardForegroundColor(context),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    preset.game,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: ThemeHelper.cardForegroundColor(context),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: enabled
                        ? InkResponse(
                            radius: 20,
                            onTap: onFavouritePressed ?? () {},
                            child: Icon(
                              preset.isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: ThemeHelper.cardForegroundColor(context),
                            ),
                          )
                        : Icon(
                            preset.isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: ThemeHelper.cardForegroundColor(context),
                          ),
                  ),
                  PresetCardMoreButton(
                    onSelected: onMoreSelected ?? (_) {},
                    enabled: enabled,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
