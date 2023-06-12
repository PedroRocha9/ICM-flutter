// profile_events.dart
abstract class ProfileEvent {}

class FetchFriends extends ProfileEvent {}

class FetchQRCode extends ProfileEvent {}

class RemoveFriend extends ProfileEvent {
  final int buddyId;

  RemoveFriend(this.buddyId);
}
