class SupabaseConfig {
  static const String projectName = 'cardealer';
  static const String projectRef = 'vxpchnbpawylgfsgibtq';

  // Live Supabase API Endpoint & Publishable Key
  static const String supabaseUrl = 'https://vxpchnbpawylgfsgibtq.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_E5DY-AaMAJBbdGuAXLFeLQ_O7Za6vCW';

  // Direct PostgreSQL Connection (port 5432)
  static const String dbPassword = r'KfN$fnuU@@nb63U';
  static const String postgresConnectionUri =
      r'postgresql://postgres:KfN$fnuU@@nb63U@db.vxpchnbpawylgfsgibtq.supabase.co:5432/postgres';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      !supabaseUrl.contains('placeholder') &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseAnonKey.contains('placeholder');
}
