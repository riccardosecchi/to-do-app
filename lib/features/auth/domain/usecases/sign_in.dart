import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign in use case.
class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}

/// Use case for signing in an existing user.
class SignIn {
  final AuthRepository repository;

  SignIn({required this.repository});

  Future<Either<Failure, AppUser>> call(SignInParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
