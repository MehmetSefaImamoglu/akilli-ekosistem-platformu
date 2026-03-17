class AppConstants {
  AppConstants._();

  // API
  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const String geminiApiKey = 'GEMINI_API_KEY';

  // Supabase Tables
  static const String usersTable = 'users';
  static const String consumptionsTable = 'consumptions';
  static const String anomaliesTable = 'anomalies';

  // Anomaly thresholds
  static const double electricityAnomalyThreshold = 150.0; // kWh
  static const double waterAnomalyThreshold = 500.0;        // litre
  static const double gasAnomalyThreshold = 80.0;           // m³

  // Cache duration
  static const Duration cacheDuration = Duration(minutes: 15);

  // Pagination
  static const int defaultPageSize = 20;
}
