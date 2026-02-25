import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Tile extends StatelessWidget {
  final int tileIndex;
  const Tile({super.key, required this.tileIndex});

  @override
  Widget build(BuildContext context) {
    final index = tileIndex > 14 ? 4 : tileIndex;
    final isSvg = index <= 3;
    final path = 'assets/tile_$index.${isSvg ? "svg" : "png"}';

    if (isSvg) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SvgPicture.asset(path),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(path),
      );
    }
  }
}
