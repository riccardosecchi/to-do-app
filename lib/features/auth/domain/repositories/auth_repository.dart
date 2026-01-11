import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';

/// Abstract interface for authentication operations.
abstract class AuthRepository {
  /// Signs up a new user with email and password.
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  });

  /// Signs in an existing user with email and password.
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Gets the currently authenticated user, if any.
  AppUser? get currentUser;

  /// Stream of authentication state changes.
  Stream<AppUser?> get authStateChanges;
}
