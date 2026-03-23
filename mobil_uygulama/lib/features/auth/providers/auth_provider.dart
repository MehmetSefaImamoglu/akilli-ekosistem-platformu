import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'auth_state.dart';

// ──────────────────────────────────────────────
// Supabase client kolaylık erişimi
// ──────────────────────────────────────────────
final supabaseClientProvider = Provider<supa.SupabaseClient>(
  (ref) => supa.Supabase.instance.client,
);

// ──────────────────────────────────────────────
// Auth Notifier
// ──────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AuthState> {
  supa.SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  @override
  Future<AuthState> build() async {
    // Mevcut oturumu kontrol et
    final session = _supabase.auth.currentSession;
    final initialState = session != null
        ? AuthStateAuthenticated(session.user)
        : const AuthStateUnauthenticated();

    // Auth değişikliklerini dinle ve state'i güncelle
    _supabase.auth.onAuthStateChange.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        state = AsyncData(AuthStateAuthenticated(user));
      } else {
        state = const AsyncData(AuthStateUnauthenticated());
      }
    });

    return initialState;
  }

  // ──────────────────────────────────────────────
  // Giriş Yap
  // ──────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
      }

      state = AsyncData(AuthStateAuthenticated(response.user!));
    } on supa.AuthException catch (e) {
      state = const AsyncData(AuthStateUnauthenticated());
      throw Exception(_turkishAuthError(e.message));
    } catch (e) {
      state = const AsyncData(AuthStateUnauthenticated());
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Kayıt Ol
  // ──────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      if (response.user == null) {
        throw Exception('Kayıt başarısız. Lütfen tekrar deneyin.');
      }

      // Kullanıcıyı public.users tablosuna ekle
      await _supabase.from('users').upsert({
        'id': response.user!.id,
        'email': email.trim(),
        'full_name': fullName.trim(),
        'role': 'user',
      });

      state = AsyncData(AuthStateAuthenticated(response.user!));
    } on supa.AuthException catch (e) {
      state = const AsyncData(AuthStateUnauthenticated());
      throw Exception(_turkishAuthError(e.message));
    } catch (e) {
      state = const AsyncData(AuthStateUnauthenticated());
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Çıkış Yap
  // ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AsyncData(AuthStateUnauthenticated());
  }

  // ──────────────────────────────────────────────
  // Yardımcı: İngilizce Supabase hatalarını Türkçeye çevir
  // ──────────────────────────────────────────────
  String _turkishAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return 'Bu e-posta adresi zaten kayıtlı.';
    }
    if (lower.contains('email not confirmed')) {
      return 'E-posta adresiniz henüz doğrulanmamış.';
    }
    if (lower.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (lower.contains('network')) {
      return 'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.';
    }
    return message;
  }
}

// ──────────────────────────────────────────────
// Provider tanımı
// ──────────────────────────────────────────────
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ──────────────────────────────────────────────
// Kolaylık: sadece oturum açmış kullanıcıyı al
// ──────────────────────────────────────────────
final currentUserProvider = Provider<supa.User?>((ref) {
  final authState = ref.watch(authProvider).valueOrNull;
  if (authState is AuthStateAuthenticated) {
    return authState.user;
  }
  return null;
});
