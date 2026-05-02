import 'package:hasicx/core/index.dart' show Failure, AppToasts;

extension FailureExt on Failure {
  void showToast() {
    AppToasts.showFailureToast(this);
  }
}
