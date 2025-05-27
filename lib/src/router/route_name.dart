part of 'router.dart';

enum RouteName {
  signIn('/auth/signin'),
  signUp('/auth/signup'),
  home('/'),
  profile('/profile');

  final String path;
  const RouteName(this.path);
}
