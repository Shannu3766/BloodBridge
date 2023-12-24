import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

class FiltersNotifier extends StateNotifier<List<String>> {
  FiltersNotifier() : super(["NoFilter", "0"]);
  void filterblood(String val, String index) {
    state = [val, index];
  }

  void clearFilter() {
    state = ["NoFilter", "0"];
  }

  void reloaddata() {
    state = [...state];
  }
}

final FiltersProvider = StateNotifierProvider<FiltersNotifier, List<String>>(
    (ref) => FiltersNotifier());
