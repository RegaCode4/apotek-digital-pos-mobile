import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

/// Widget Logo Apotek Digital SVG persis seperti di Web Layout / Sidebar
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBorder;

  const AppLogo({
    super.key,
    this.size = 32.0,
    this.showBorder = true,
  });

  static const String rawSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="32" height="32">
  <defs>
    <linearGradient id="g" x1="0" y1="1" x2="1" y2="0">
      <stop offset="0" stop-color="#34d399"/>
      <stop offset="1" stop-color="#2dd4bf"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="32" height="32" rx="8" fill="url(#g)"/>
  <g transform="translate(6 6) scale(0.83)"
     fill="none" stroke="#ffffff" stroke-width="2"
     stroke-linecap="round" stroke-linejoin="round">
    <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/>
    <path d="m8.5 8.5 7 7"/>
  </g>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final logoWidget = SvgPicture.string(
      rawSvg,
      width: size,
      height: size,
    );

    if (!showBorder) return logoWidget;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBrutal, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.darkBrutal,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: logoWidget,
      ),
    );
  }
}
