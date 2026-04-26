// lib/core/services/gemini_service.dart
//
// Hafta 6 — Gemini AI Proxy Servisi
//
// Güvenlik mimarisi:
//   Flutter → [dio POST] → Next.js /api/gemini/explain → Google Gemini API
//   GEMINI_API_KEY Flutter'a gömülmez, yalnızca Next.js sunucu tarafında bulunur.
//
// Kural 2 uyumu:
//   - analyzeAnomaly() asla exception fırlatmaz; hata durumunda boş string döner.
//   - Çağıran taraf (provider) boş string kontrolüyle UI mesajını yönetir.

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import '../../models/anomaly_model.dart';

class GeminiService {
  GeminiService() {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:3000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  late final Dio _dio;
  final _log = Logger();

  // ─────────────────────────────────────────────────────────────
  // analyzeAnomaly
  //
  // Next.js /api/gemini/explain endpoint'ine POST atar.
  //   Request body → anomali detayları
  //   Response     → { "explanation": "Türkçe açıklama..." }
  //
  // Dönüş:
  //   - Başarı  → Türkçe açıklama metni (non-empty String)
  //   - Hata    → '' (boş string); asla exception fırlatılmaz
  // ─────────────────────────────────────────────────────────────
  Future<String> analyzeAnomaly(AnomalyModel anomaly) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/gemini/explain',
        data: {
          'anomaly_id': anomaly.id,
          'description': anomaly.description,
          'detected_value': anomaly.detectedValue,
          'expected_value': anomaly.expectedValue,
          'severity': anomaly.severity.name,
        },
      );

      final data = response.data;
      if (data == null) {
        _log.w('GeminiService: boş yanıt alındı');
        return '';
      }

      final explanation = data['explanation'] as String? ?? '';
      if (explanation.isEmpty) {
        _log.w('GeminiService: explanation alanı boş');
      }
      return explanation;
    } on DioException catch (e) {
      _log.e(
        'GeminiService DioException',
        error: e,
        stackTrace: e.stackTrace,
      );
      return '';
    } catch (e, st) {
      _log.e('GeminiService beklenmeyen hata', error: e, stackTrace: st);
      return '';
    }
  }
}
