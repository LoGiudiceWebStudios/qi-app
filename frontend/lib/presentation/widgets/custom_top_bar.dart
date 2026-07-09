import 'package:flutter/material.dart';
import '../../core/theme/app_fonts.dart';

class CustomTopBar extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Widget? leading;
  final IconData? icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final double iconSize;
  final double iconContainerSize;
  final bool showStar;
  final Color starColor;
  final double horizontalPadding;
  final double topSpacing;
  final double bottomSpacing;
  final double titleSpacing;
  final TextStyle? titleStyle;

  const CustomTopBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.leading,
    this.icon,
    this.iconColor = Colors.white,
    this.iconBackgroundColor = const Color(0x38FFFFFF),
    this.iconSize = 33,
    this.iconContainerSize = 34,
    this.showStar = false,
    this.starColor = const Color(0xFFFFF4B1),
    this.horizontalPadding = 20,
    this.topSpacing = 18,
    this.bottomSpacing = 14,
    this.titleSpacing = 12,
    this.titleStyle,
  }) : assert(
         leading != null || icon != null,
         'Provide leading or icon for CustomTopBar',
       );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final resolvedTitleStyle = (titleStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ))
        .copyWith(fontFamily: AppFonts.openSauce);

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topInset + topSpacing,
        horizontalPadding,
        bottomSpacing,
      ),
      child: Row(
        children: [
          leading ?? _buildDefaultIcon(),
          SizedBox(width: titleSpacing),
          Flexible(
            child: Text(
              title,
              style: resolvedTitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return SizedBox(
      width: iconContainerSize,
      height: iconContainerSize,
      child: Center(child: Icon(icon, color: iconColor, size: iconSize)),
    );
  }
}
