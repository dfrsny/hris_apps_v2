import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hris_apps/features/auth/domain/failures/auth_failure.dart';
import 'package:hris_apps/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource(this._client);

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Login gagal, silakan coba lagi.');
      }
      return await _loadCurrentUser(user);
    } on AuthException catch (e) {
      throw AuthFailure(_translateAuthError(e));
    }
  }

  String _translateAuthError(AuthException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Hubungi HR atau Super Admin.';
    }
    if (code == 'over_request_rate_limit' || message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
    }
    if (code == 'user_banned' || message.contains('banned')) {
      return 'Akun ini dinonaktifkan.';
    }
    return 'Login gagal, silakan coba lagi.';
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      try {
        return await _loadCurrentUser(user);
      } on AuthFailure {
        return null;
      }
    });
  }

  /// Mengambil profile dan status Lead. Akun nonaktif atau tanpa profile ditolak.
  Future<UserModel> _loadCurrentUser(User user) async {
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null || profile['is_active'] != true) {
      await _client.auth.signOut();
      throw const AuthFailure('Akun tidak aktif atau belum terdaftar');
    }

    // ignore: inference_failure_on_function_invocation
    final isLead = (await _client.rpc('is_lead')) as bool? ?? false;

    return UserModel.fromProfile(
      id: user.id,
      email: user.email,
      profile: profile,
      isLead: isLead,
    );
  }
}
