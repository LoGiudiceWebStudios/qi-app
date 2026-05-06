import 'package:flutter_riverpod/flutter_riverpod.dart';

// Questo provider terrà a mente un numero (0, 1, 2...) che rappresenta il tab attivo.
// Di default parte da 0 (il primo tab).
class BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, int>(
  BottomNavIndexNotifier.new,
);
