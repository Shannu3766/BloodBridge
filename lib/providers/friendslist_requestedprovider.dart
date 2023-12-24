import 'package:flutter_riverpod/flutter_riverpod.dart';

class friendlist_requestednotifier extends StateNotifier<List<String>> {
  friendlist_requestednotifier() : super([]);
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

  bool dohavefriends() {
    if (state.length == 0) {
      return true;
    }
    return false;
  }
}

final friendlist_requestedprovider =
    StateNotifierProvider<friendlist_requestednotifier, List<String>>(
  (ref) => friendlist_requestednotifier(),
);
