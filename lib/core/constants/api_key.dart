class ApiKeys {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const supabasePublishKey = String.fromEnvironment(
    'SUPABASE_PUBLISH_KEY',
  );
}
