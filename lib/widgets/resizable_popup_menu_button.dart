import 'package:flutter/material.dart';

/// Popup menu icon button that can be resized without restrictions.
class ResizablePopupMenuButton<T> extends PopupMenuButton<T> {
  const ResizablePopupMenuButton({
    super.key,
    required super.itemBuilder,
    super.initialValue,
    super.onSelected,
    super.onCanceled,
    super.tooltip,
    super.elevation,
    super.padding,
    super.icon,
    super.iconSize,
    super.offset,
    super.enabled = true,
    super.shape,
    super.color,
    super.enableFeedback,
    super.constraints,
    super.position,
  });

  @override
  ResizablePopupMenuButtonState<T> createState() =>
      ResizablePopupMenuButtonState<T>();
}

class ResizablePopupMenuButtonState<T> extends PopupMenuButtonState<T> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Tooltip(
        message: widget.tooltip ?? 'Show menu',
        child: InkResponse(
          radius: widget.iconSize ?? 20,
          onTap: widget.enabled ? showButtonMenu : null,
          enableFeedback: widget.enableFeedback ??
              PopupMenuTheme.of(context).enableFeedback ??
              true,
          child: widget.icon ?? const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
