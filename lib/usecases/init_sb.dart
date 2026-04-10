import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late SupabaseClient fishroomAdmin;

Future<void> initSB() async {
  fishroomAdmin = SupabaseClient(
    dotenv.env['FISHROOM_SUPABASE_URL'] ?? '',
    dotenv.env['FISHROOM_SUPABASE_SERVICE_KEY'] ?? '',
  );
}
