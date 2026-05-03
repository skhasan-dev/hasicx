import 'package:flutter/material.dart';

enum ViewState { idle, busy, complete }

class ViewStateProvider extends ChangeNotifier {
  ViewState _state = ViewState.idle;

  bool get isLoading => _state == ViewState.busy;

  void setViewState(ViewState state, {bool notify = false}) {
    _state = state;
    if (notify) notifyListeners();
  }
}
