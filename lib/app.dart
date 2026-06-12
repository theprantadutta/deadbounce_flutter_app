import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/restore_session.dart';
import 'features/auth/domain/usecases/sign_in_as_guest.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

/// Composition root: wires data sources → repository → use cases → cubit,
/// and mounts the router + theme. Kept manual (no service locator) while
/// the graph is this small.
class DeadbounceApp extends StatefulWidget {
  const DeadbounceApp({super.key});

  @override
  State<DeadbounceApp> createState() => _DeadbounceAppState();
}

class _DeadbounceAppState extends State<DeadbounceApp> {
  late final TokenStorage _tokenStorage = TokenStorage();
  late final ApiClient _apiClient = ApiClient(_tokenStorage);
  late final AuthRepository _authRepository = AuthRepositoryImpl(
    firebaseDataSource: AuthFirebaseDataSource(),
    remoteDataSource: AuthRemoteDataSource(_apiClient),
    tokenStorage: _tokenStorage,
  );
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepository,
      child: BlocProvider(
        create: (_) => AuthCubit(
          signInWithEmail: SignInWithEmail(_authRepository),
          signUpWithEmail: SignUpWithEmail(_authRepository),
          signInWithGoogle: SignInWithGoogle(_authRepository),
          signInAsGuest: SignInAsGuest(_authRepository),
          restoreSession: RestoreSession(_authRepository),
          signOut: SignOut(_authRepository),
        ),
        child: MaterialApp.router(
          title: 'Deadbounce',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: _router,
        ),
      ),
    );
  }
}
