import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      
      switch (e.code) {
        case 'user-not-found':
          _setErrorMessage('No existe una cuenta con este correo electrónico.');
          break;
        case 'wrong-password':
          _setErrorMessage('Contraseña incorrecta.');
          break;
        case 'invalid-email':
          _setErrorMessage('El formato del correo electrónico no es válido.');
          break;
        default:
          _setErrorMessage('Error al iniciar sesión: ${e.message}');
      }
      
      return false;
    } catch (e) {
      _setLoading(false);
      _setErrorMessage('Error inesperado al iniciar sesión.');
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Actualizar el nombre del usuario
      await userCredential.user?.updateDisplayName(name);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      
      switch (e.code) {
        case 'email-already-in-use':
          _setErrorMessage('Ya existe una cuenta con este correo electrónico.');
          break;
        case 'weak-password':
          _setErrorMessage('La contraseña es demasiado débil.');
          break;
        case 'invalid-email':
          _setErrorMessage('El formato del correo electrónico no es válido.');
          break;
        default:
          _setErrorMessage('Error al crear la cuenta: ${e.message}');
      }
      
      return false;
    } catch (e) {
      _setLoading(false);
      _setErrorMessage('Error inesperado al crear la cuenta.');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setErrorMessage(null);
      
      await _auth.sendPasswordResetEmail(email: email);
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      
      switch (e.code) {
        case 'user-not-found':
          _setErrorMessage('No existe una cuenta con este correo electrónico.');
          break;
        case 'invalid-email':
          _setErrorMessage('El formato del correo electrónico no es válido.');
          break;
        default:
          _setErrorMessage('Error al restablecer la contraseña: ${e.message}');
      }
      
      return false;
    } catch (e) {
      _setLoading(false);
      _setErrorMessage('Error inesperado al restablecer la contraseña.');
      return false;
    }
  }
}