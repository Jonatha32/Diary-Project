import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'emotions_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Mostrar un indicador de carga mientras se verifica el estado de autenticación
    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Redirigir según el estado de autenticación
    if (authService.isAuthenticated) {
      return const EmotionsScreen();
    } else {
      return const LoginScreen();
    }
  }
}