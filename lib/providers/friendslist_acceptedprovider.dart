import 'package:flutter_riverpod/flutter_riverpod.dart';

class friendlist_acceptednotifier extends StateNotifier<List<String>> {
  friendlist_acceptednotifier() : super([]);
  void add_friend(String id) {
    if (!state.contains(id)) {
      state = [id, ...state];
    }
  }

  void removeFriend(String id) {
    state = state.where((friendId) => friendId != id).toList();
  }

  bool is_friend(String id) {
    if (state.contains(id)) {
      return true;
    }
    return false;
  }
}

final friendlist_acceptedprovider =
    StateNotifierProvider<friendlist_acceptednotifier, List<String>>(
  (ref) => friendlist_acceptednotifier(),
);
