library drop_shadow;

import 'dart:ui';

import 'package:flutter/material.dart';

class DropShadow extends StatelessWidget {
  const DropShadow({
    required this.child,
    this.blurRadius = 10.0,
    this.borderRadius = 0.0,
    this.offset = const Offset(10, 10),
    this.opacity = 1.0,
    this.spread = 1.0,
    this.color,
    super.key,
  });

  final Widget child;
  final double blurRadius;
  final double borderRadius;
  final Offset offset;
  final double opacity;
  final double spread;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    var left = 2.0;
    var right = 2.0;
    var top = 2.0;
    var bottom = 2.0;

    // Điều chỉnh padding dựa trên các thông số offset, blur và spread
    left = (offset.dx.abs() + (blurRadius * 2)) * spread;
    right = (offset.dx.abs() + (blurRadius * 2)) * spread;
    top = (offset.dy.abs() + (blurRadius * 2)) * spread;
    bottom =0;

    return ClipRRect(
      child: Padding(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: Stack(
          children: [
            // Áp dụng bóng đổ ở một vị trí nhất định
            for (var dx in [-offset.dx, offset.dx])
              for (var dy in [-offset.dy, offset.dy])
                Transform.translate(
                  offset: Offset(dx, dy),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Opacity(
                      opacity: opacity,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          color!,
                          BlendMode.srcIn,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),

            // Áp dụng hiệu ứng blur cho nền
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurRadius,
                  sigmaY: blurRadius,
                ),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // Vật thể chính với borderRadius
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
