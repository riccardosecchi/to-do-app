import 'package:dartz/dartz.dart';
import 'package:todo_app/core/error/failures.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out the current user.
class SignOut {
  final AuthRepository repository;

  SignOut({required this.repository});

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
