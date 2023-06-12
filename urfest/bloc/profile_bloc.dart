// profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'profile_events.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial());

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchFriends) {
      yield ProfileLoading();
      try {
        final response = await http.get(Uri.parse(
            'http://192.168.43.8:8000/user/2/buddies?content=username'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<String> friends = List<String>.from(data);
          yield FriendsLoaded(friends);
        } else {
          yield ProfileError("Failed to fetch friends");
        }
      } catch (e) {
        yield ProfileError(e.toString());
      }
    } else if (event is FetchQRCode) {
      yield ProfileLoading();
      try {
        final response =
            await http.get(Uri.parse('http://192.168.43.8:8000/qrcode/3'));
        if (response.statusCode == 200) {
          yield QRCodeLoaded(response.bodyBytes);
        } else {
          yield ProfileError("Failed to fetch QR code");
        }
      } catch (e) {
        yield ProfileError(e.toString());
      }
    } else if (event is RemoveFriend) {
      try {
        final response = await http.delete(
          Uri.parse('http://192.168.43.8:8000/user/2/buddies/${event.buddyId}'),
        );
        if (response.statusCode != 200) {
          yield ProfileError("Failed to remove friend");
        }
      } catch (e) {
        yield ProfileError(e.toString());
      }
    }
  }
}
