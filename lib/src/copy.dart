import 'package:flutter/widgets.dart';

class GuardianCopy {
  const GuardianCopy(this.isZh);

  final bool isZh;

  static GuardianCopy of(BuildContext context) =>
      GuardianCopy(Localizations.localeOf(context).languageCode == 'zh');

  String t(String zh, String en) => isZh ? zh : en;
}
