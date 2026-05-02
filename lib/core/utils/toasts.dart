import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hasicx/core/index.dart' show Failure;

class AppToasts {
  static void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
  }

  static void showFailureToast(Failure? failure, {String? successMsg}) {
    if (failure == null && successMsg == null) return;
    Fluttertoast.showToast(
      msg: failure?.message ?? successMsg ?? 'Unknown Error Occurred',
      backgroundColor: failure != null ? Colors.red : null,
      textColor: failure != null ? Colors.white : null,
      toastLength: Toast.LENGTH_LONG,
    );
  }
}
