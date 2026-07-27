import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/data/guardian_database.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() async {
    await GuardianDatabase.useForTesting(GuardianDatabase.memory());
  });
  tearDown(GuardianDatabase.resetAfterTesting);
  await testMain();
}
