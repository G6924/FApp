import 'package:bloc/bloc.dart';
import 'package:project/services/auth/auth_provider.dart';
import 'package:project/services/auth/bloc/auth_event.dart';
import 'package:project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;

  AuthBloc(this.provider) : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventLogIn>(_onLogIn);
    on<AuthEventLogOut>(_onLogOut);
    on<AuthEventShouldRegister>(_onShouldRegister);
  }

  Future<void> _onInitialize(AuthEventInitialize event, Emitter<AuthState> emit) async {
    await provider.initialize();
    final user = provider.currentUser;
    if (user == null) {
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } else if (!user.isEmailVerified) {
      emit(const AuthStateNeedsVerification(isLoading: false));
    } else {
      emit(AuthStateLoggedIn(user: user, isLoading: false));
    }
  }

  Future<void> _onSendEmailVerification(AuthEventSendEmailVerification event, Emitter<AuthState> emit) async {
    await provider.sendEmailVerification();
    emit(state);
  }

  Future<void> _onRegister(AuthEventRegister event, Emitter<AuthState> emit) async {
    final email = event.email;
    final password = event.password;
    try {
      await provider.createUser(email: email, password: password);
      await provider.sendEmailVerification();
      emit(const AuthStateNeedsVerification(isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateRegistering(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogIn(AuthEventLogIn event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoggedOut(exception: null, isLoading: true, loadingText: 'Please wait while I log you in'));

    await Future.delayed(const Duration(seconds: 3));

    final email = event.email;
    final password = event.password;

    try {
      final user = await provider.logIn(email: email, password: password);
      if (!user.isEmailVerified) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogOut(AuthEventLogOut event, Emitter<AuthState> emit) async {
    try {
      await provider.logOut();
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }

  void _onShouldRegister(AuthEventShouldRegister event, Emitter<AuthState> emit) {
import 'package:bloc/bloc.dart';
import 'package:project/services/auth/auth_provider.dart';
import 'package:project/services/auth/bloc/auth_event.dart';
import 'package:project/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;

  AuthBloc(this.provider) : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventLogIn>(_onLogIn);
    on<AuthEventLogOut>(_onLogOut);
    on<AuthEventShouldRegister>(_onShouldRegister);
  }

  Future<void> _onInitialize(AuthEventInitialize event, Emitter<AuthState> emit) async {
    await provider.initialize();
    final user = provider.currentUser;
    if (user == null) {
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } else if (!user.isEmailVerified) {
      emit(const AuthStateNeedsVerification(isLoading: false));
    } else {
      emit(AuthStateLoggedIn(user: user, isLoading: false));
    }
  }

  Future<void> _onSendEmailVerification(AuthEventSendEmailVerification event, Emitter<AuthState> emit) async {
    await provider.sendEmailVerification();
    emit(state);
  }

  Future<void> _onRegister(AuthEventRegister event, Emitter<AuthState> emit) async {
    final email = event.email;
    final password = event.password;
    try {
      await provider.createUser(email: email, password: password);
      await provider.sendEmailVerification();
      emit(const AuthStateNeedsVerification(isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateRegistering(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogIn(AuthEventLogIn event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoggedOut(exception: null, isLoading: true, loadingText: 'Please wait while I log you in'));

    await Future.delayed(const Duration(seconds: 3));

    final email = event.email;
    final password = event.password;

    try {
      final user = await provider.logIn(email: email, password: password);
      if (!user.isEmailVerified) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogOut(AuthEventLogOut event, Emitter<AuthState> emit) async {
    try {
      await provider.logOut();
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }

  void _onShouldRegister(AuthEventShouldRegister event, Emitter<AuthState> emit) {