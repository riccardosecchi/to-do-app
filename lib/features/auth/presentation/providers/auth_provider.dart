import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/domain/usecases/sign_in.dart';
import 'package:todo_app/features/auth/domain/usecases/sign_out.dart';
import 'package:todo_app/features/auth/domain/usecases/sign_up.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SignIn signInUseCase;
  final SignUp signUpUseCase;
  final SignOut signOutUseCase;
  final AuthRepository repository;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthProvider({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.repository,
  }) {
    _init();
  }

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _init() {
    _user = repository.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    _authSubscription = repository.authStateChanges.listen((user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await signInUseCase(SignInParams(
      email: email,
      password: password,
    ));

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message ?? 'Sign in failed';
        notifyListeners();
        return false;
      },
      (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signUp({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await signUpUseCase(SignUpParams(
      email: email,
      password: password,
    ));

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message ?? 'Sign up failed';
        notifyListeners();
        return false;
      },
      (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await signOutUseCase();

    result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message ?? 'Sign out failed';
      },
      (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
      },
    );
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
