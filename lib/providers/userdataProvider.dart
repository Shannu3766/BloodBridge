import 'package:flutter_riverpod/flutter_riverpod.dart';

class userdataNotifier extends StateNotifier<List<String>> {
  userdataNotifier() : super([]);
  void addstate_dist(String userUid, String userState, String userDist,
      String username, String phone, String photourl, String Bloodgroup,String number_of_donations) {
    state = [
      userUid,
      userState,
      userDist,
      username,
      phone,
      photourl,
      Bloodgroup,
      number_of_donations,
    ];
  }
}

final userdataProvider = StateNotifierProvider<userdataNotifier, List<String>>(
    (ref) => userdataNotifier());
