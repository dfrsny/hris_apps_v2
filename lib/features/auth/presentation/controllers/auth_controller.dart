import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:hris_apps/features/auth/domain/entities/user_entity.dart';
import 'package:hris_apps/features/auth/domain/failures/auth_failure.dart';
import 'package:hris_apps/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:hris_apps/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:hris_apps/features/auth/domain/usecases/watch_auth_state_usecase.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required WatchAuthStateUseCase watchAuthStateUseCase,
  }) : _signIn = signInUseCase,
       _signOut = signOutUseCase {
    _subscription = watchAuthStateUseCase().listen((user) {
      _user = user;
      _isReady = true;
      notifyListeners();
    });
  }

  final SignInUseCase _signIn;
  final SignOutUseCase _signOut;

  StreamSubscription<UserEntity?>? _subscription;
  UserEntity? _user;
  bool _isReady = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserEntity? get user => _user;
  bool get isReady => _isReady;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> signIn({required String email, required String password}) {
    return _execute(() => _signIn(email: email, password: password));
  }

  Future<void> signOut() {
    return _execute(() => _signOut());
  }

  Future<void> _execute(Future<Object?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan, silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
