import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

/// Монохромная SVG-иконка заморозки вместо эмодзи ❄.
class FreezeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const FreezeIcon({
    super.key,
    this.size = 14,
    this.color = AppColors.freezeActive,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/snowflake.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
