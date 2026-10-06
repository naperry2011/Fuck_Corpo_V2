import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          final count = (c.maxWidth / 8).floor();
          return Row(
            children: List.generate(
              count,
              (_) => Expanded(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Stamp extends StatelessWidget {
  const Stamp(this.text, {super.key, this.angle = -0.14, this.fontSize = 18});

  final String text;
  final double angle;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: color, width: 2.5)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: fontSize, letterSpacing: 2)),
      ),
    );
  }
}

class LineItem extends StatelessWidget {
  const LineItem(this.label, this.value, {super.key, this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: DefaultTextStyle.merge(
        style: style,
        child: LayoutBuilder(
          builder: (context, c) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label)),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth * 0.55),
                child: Text(value, textAlign: TextAlign.end),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeChip extends StatelessWidget {
  const ModeChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.locked = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.onSurface : null,
          border: Border.all(color: scheme.onSurface),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              Icon(Icons.lock_outline,
                  size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? scheme.surface
                    : locked
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
