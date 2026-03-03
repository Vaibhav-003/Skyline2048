import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skyline2048/models/tile.dart';

/// Animated tile widget that handles:
///   - Spawn animation  : scale 0 → 1 (elastic pop) when [tile.isNew] == true
///   - Merge animation  : scale 1 → 1.15 → 1 (pulse) when [tile.isMerged] == true
///
/// Slide animation is handled externally by [AnimatedPositioned] in GameBoard,
/// which tracks each tile by its unique [Tile.id] via a [ValueKey].
class TileWidget extends StatefulWidget {
  final Tile tile;
  final double size;
  final double borderRadius;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    required this.borderRadius,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    if (widget.tile.isNew) {
      _runSpawnAnimation();
    } else if (widget.tile.isMerged) {
      _runMergeAnimation();
    } else {
      // No animation — just show at full scale.
      _scale = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger merge pulse when provider marks this tile as merged.
    if (widget.tile.isMerged && !oldWidget.tile.isMerged) {
      _runMergeAnimation();
    }
    // Re-trigger spawn if somehow a new tile reuses the same widget slot.
    if (widget.tile.isNew && !oldWidget.tile.isNew) {
      _runSpawnAnimation();
    }
  }

  void _runSpawnAnimation() {
    _controller.duration = const Duration(milliseconds: 180);
    _scale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward(from: 0);
  }

  void _runMergeAnimation() {
    _controller.duration = const Duration(milliseconds: 180);
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Center(
          child: SvgPicture.asset(
            'assets/tile_${widget.tile.value}.svg',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
          ),
        ),
        /*Text(
            pow(2, widget.tile.value).toString(),
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ), */
      ),
    );
  }
}
