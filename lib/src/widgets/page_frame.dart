import 'package:flutter/material.dart';

class GuardianPageFrame extends StatelessWidget {
  const GuardianPageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontal = constraints.maxWidth < 600 ? 16.0 : 32.0;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 48),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ),
                ],
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      );
    },
  );
}
