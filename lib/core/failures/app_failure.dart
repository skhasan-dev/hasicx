import 'package:hasicx/core/index.dart' show Failure;

class AppFailure extends Failure {
  const AppFailure(super.message);

  @override
  String toString() => '$runtimeType: $message';
}
