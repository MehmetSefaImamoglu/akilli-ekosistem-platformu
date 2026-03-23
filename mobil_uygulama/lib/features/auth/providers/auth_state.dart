import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Uygulamanın kimlik doğrulama durumunu temsil eden sealed class.
sealed class AuthState {
  const AuthState();
}

/// Uygulama ilk başladığında — session kontrolü henüz tamamlanmadı.
final class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Kullanıcı başarıyla giriş yapmış.
final class AuthStateAuthenticated extends AuthState {
  final supa.User user;
  const AuthStateAuthenticated(this.user);
}

/// Kullanıcı giriş yapmamış veya çıkış yapmış.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}
