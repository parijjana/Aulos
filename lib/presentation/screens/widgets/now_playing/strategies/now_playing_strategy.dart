import 'package:flutter/material.dart';
import 'package:aulos/presentation/viewmodels/player_view_model.dart';

abstract class NowPlayingStrategy {
  Widget buildControls(BuildContext context, PlayerViewModel vm, ThemeData theme, double buttonSize, double primarySize);
  Widget buildContent(BuildContext context, PlayerViewModel vm, ThemeData theme);
  String get sectionLabel;
  bool get showProgress => true;
}
