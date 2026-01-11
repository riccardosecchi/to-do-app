import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/supabase_config.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/tasks/data/datasources/task_remote_data_source.dart';
import 'features/tasks/data/repositories/task_repository_supabase_impl.dart';
import 'features/tasks/domain/usecases/get_tasks.dart';
import 'features/tasks/domain/usecases/add_task.dart';
import 'features/tasks/domain/usecases/update_task_status.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'features/tasks/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Setup Auth dependencies
  final authDataSource = AuthRemoteDataSourceImpl(client: SupabaseConfig.client);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
  final signIn = SignIn(repository: authRepository);
  final signUp = SignUp(repository: authRepository);
  final signOut = SignOut(repository: authRepository);

  // Setup Task dependencies
  final taskDataSource = TaskRemoteDataSourceImpl(client: SupabaseConfig.client);
  final taskRepository = TaskRepositorySupabaseImpl(remoteDataSource: taskDataSource);
  final getTasks = GetTasks(repository: taskRepository);
  final addTask = AddTask(repository: taskRepository);
  final updateTaskStatus = UpdateTaskStatus(repository: taskRepository);
  final deleteTask = DeleteTask(repository: taskRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            signInUseCase: signIn,
            signUpUseCase: signUp,
            signOutUseCase: signOut,
            repository: authRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            getTasks: getTasks,
            addTask: addTask,
            updateTaskStatus: updateTaskStatus,
            deleteTask: deleteTask,
          ),
        ),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state navigation.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking auth state
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on authentication status
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
