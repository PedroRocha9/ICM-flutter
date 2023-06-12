// profile_state.dart
import 'dart:typed_data';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class FriendsLoaded extends ProfileState {
  final List<String> friends;

  FriendsLoaded(this.friends);
}

class QRCodeLoaded extends ProfileState {
  final Uint8List qrCodeImageData;

  QRCodeLoaded(this.qrCodeImageData);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
