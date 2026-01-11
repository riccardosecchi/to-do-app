import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';

/// Exception for authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Remote data source for authentication using Supabase.
abstract class AuthRemoteDataSource {
  Future<AppUser> signUp({required String email, required String password});
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;
}

/// Implementation of [AuthRemoteDataSource] using Supabase.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed. Please try again.');
      }

      return _mapUserToAppUser(response.user!);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed. Invalid credentials.');
      }

      return _mapUserToAppUser(response.user!);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _mapUserToAppUser(user);
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return _mapUserToAppUser(user);
    });
  }

  AppUser _mapUserToAppUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }
}
