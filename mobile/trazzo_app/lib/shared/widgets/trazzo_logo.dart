import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Trazzo logo: big capital T + "razzo" for goTrazzo.com branding.
class TrazzoLogo extends StatelessWidget {
  const TrazzoLogo({
    super.key,
    this.size = LogoSize.large,
    this.showTagline = true,
  });

  final LogoSize size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final isCompact = size == LogoSize.compact;
    final tSize = isCompact ? 36.0 : 56.0;
    final razzoSize = isCompact ? 28.0 : 40.0;
    final taglineSize = isCompact ? 10.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'T',
              style: TextStyle(
                fontSize: tSize,
                fontWeight: FontWeight.w800,
                color: TrazzoPrimary,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
            Text(
              'razzo',
              style: TextStyle(
                fontSize: razzoSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            'goTrazzo.com',
            style: TextStyle(
              fontSize: taglineSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}

enum LogoSize { large, compact }
