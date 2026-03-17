// lib/models/user_model.dart
//
// Fonksiyonel Programlama ilkesi: Immutable veri modeli.
// @freezed anotasyonu sayesinde:
//   - Tüm alanlar final (değiştirilemez).
//   - copyWith() otomatik üretilir — yeni state fonksiyonel olarak türetilir.
//   - fromJson / toJson json_serializable tarafından üretilir.
//   - == ve hashCode değer eşitliği (structural equality) sağlar.
//
// Üretilen dosyayı oluşturmak için:
//   flutter pub run build_runner build --delete-conflicting-outputs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    /// Supabase auth.users.id (UUID)
    required String id,

    /// Kullanıcı e-posta adresi
    required String email,

    /// Tam ad (opsiyonel)
    @JsonKey(name: 'full_name') String? fullName,

    /// Profil fotoğrafı URL (opsiyonel)
    @JsonKey(name: 'avatar_url') String? avatarUrl,

    /// Kullanıcı rolü: 'admin' | 'user'
    @Default('user') String role,

    /// Kayıt tarihi
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserModel;

  /// JSON'dan immutable model üret (json_serializable tarafından sağlanır)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
