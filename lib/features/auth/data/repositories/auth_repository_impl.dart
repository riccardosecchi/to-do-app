import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using Supabase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: $e'));
    }
  }

  @override
  AppUser? get currentUser => remoteDataSource.currentUser;

  @override
  Stream<AppUser?> get authStateChanges => remoteDataSource.authStateChanges;
}
