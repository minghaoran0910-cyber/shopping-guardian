import 'package:flutter/material.dart';

import 'price_watch.dart';

/// A tiny sparkline chart showing price history.
///
/// Uses only `CustomPainter` — no external charting dependency.
class PriceSparkline extends StatelessWidget {
  const PriceSparkline({
    super.key,
    required this.snapshots,
    this.height = 48,
    this.color,
  });

  final List<PriceSnapshot> snapshots;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (snapshots.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final lineColor = color ?? theme.colorScheme.primary;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(
          snapshots: snapshots,
          lineColor: lineColor,
          fillColor: lineColor.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.snapshots,
    required this.lineColor,
    required this.fillColor,
  });

  final List<PriceSnapshot> snapshots;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (snapshots.length < 2) return;

    final prices = snapshots.map((s) => s.price).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final range = maxP - minP;

    // Avoid division by zero when all prices are the same.
    final yScale = range == 0 ? 0.0 : 1.0 / range;
    final xStep = size.width / (snapshots.length - 1);
    const padding = 4.0;
    final drawHeight = size.height - padding * 2;

    final points = <Offset>[];
    for (var i = 0; i < snapshots.length; i++) {
      final x = i * xStep;
      final yNorm = range == 0 ? 0.5 : (prices[i] - minP) * yScale;
      // Invert Y so lower price = lower on screen.
      final y = padding + drawHeight * (1 - yNorm);
      points.add(Offset(x, y));
    }

    // Fill area under the line.
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Draw the line.
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Draw dots at each data point.
    final dotPaint = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      snapshots != oldDelegate.snapshots || lineColor != oldDelegate.lineColor;
}
