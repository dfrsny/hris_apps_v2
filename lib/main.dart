import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hris_apps/core/constants/api_key.dart';
import 'package:hris_apps/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:hris_apps/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hris_apps/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:hris_apps/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:hris_apps/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:hris_apps/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hris_apps/features/auth/presentation/pages/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    publishableKey: ApiKeys.supabasePublishKey,
  );

  // Data layer
  final dataSource = AuthRemoteDataSource(Supabase.instance.client);
  final repository = AuthRepositoryImpl(dataSource);

  // Presentation layer
  final authController = AuthController(
    signInUseCase: SignInUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    watchAuthStateUseCase: WatchAuthStateUseCase(repository),
  );

  runApp(MainApp(authController: authController));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(controller: authController),
    );
  }
}
