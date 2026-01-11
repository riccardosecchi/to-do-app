import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

/// Parameters for sign up use case.
class SignUpParams {
  final String email;
  final String password;

  const SignUpParams({required this.email, required this.password});
}

/// Use case for signing up a new user.
class SignUp {
  final AuthRepository repository;

  SignUp({required this.repository});

  Future<Either<Failure, AppUser>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
    );
  }
}
