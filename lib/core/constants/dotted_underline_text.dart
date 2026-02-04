import 'package:flutter/material.dart';

class DottedUnderlineText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color underlineColor;

  const DottedUnderlineText({
    super.key,
    required this.text,
    required this.style,
    this.underlineColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Text(text, style: style),
        Positioned(
          bottom: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 100.0; // Fallback width if maxWidth is infinite

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  (maxWidth ~/ 5).toInt(),
                  (index) => Container(
                    width: 3,
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: underlineColor,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
