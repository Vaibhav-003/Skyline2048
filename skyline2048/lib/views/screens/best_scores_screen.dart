import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skyline2048/app_theme.dart';
import 'package:skyline2048/data/repositories/board_repository.dart';
import 'package:skyline2048/models/score_entry.dart';

class BestScoresScreen extends StatelessWidget {
  const BestScoresScreen({super.key});

  /// e.g. "5 Mar 2026"
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final List<ScoreEntry> scores = BoardRepository().loadTopScores();

    return Scaffold(
      appBar: AppBar(
        title: Text('Best Scores', style: AppTheme.titleStyle),
        backgroundColor: AppTheme.cardColor,
        elevation: 0,
      ),
      body: scores.isEmpty ? _buildEmptyState() : _buildScoreList(scores),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Best Scores available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Play a game to record your scores!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreList(List<ScoreEntry> scores) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = scores[index];
        return _ScoreCard(
          rank: index + 1,
          entry: entry,
          formattedDate: _formatDate(entry.date),
        );
      },
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int rank;
  final ScoreEntry entry;
  final String formattedDate;

  const _ScoreCard({
    required this.rank,
    required this.entry,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final rankColors = [
      const Color(0xFFFFD700), // Gold   #1
      const Color(0xFFC0C0C0), // Silver #2
      const Color(0xFFCD7F32), // Bronze #3
      Colors.blueGrey.shade100,
      Colors.blueGrey.shade100,
    ];
    final rankColor = rank <= rankColors.length
        ? rankColors[rank - 1]
        : Colors.blueGrey.shade100;

    // Clamp tileValue to the range of available SVGs (1–14).
    final tileValue = entry.highestTileValue.clamp(1, 14);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Rank badge ──────────────────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Highest tile SVG ────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset(
                'assets/tile_$tileValue.svg',
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(width: 16),

            // ── Score + date ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.score} pts',
                    style: AppTheme.scoreStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
