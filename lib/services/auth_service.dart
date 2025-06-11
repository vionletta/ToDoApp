import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '148371012524-4umc6mkfr7bhku6ji2vu2ne7uunanjjo.apps.googleusercontent.com',
        scopes: [
          'email',
          'https://www.googleapis.com/auth/calendar',
          'https://www.googleapis.com/auth/calendar.events',
        ],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/calendar',
          'https://www.googleapis.com/auth/calendar.events',
        ],
      );
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Register with email and password
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web platform
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        
        // Add scopes
        googleProvider.addScope('email');
        googleProvider.addScope('https://www.googleapis.com/auth/calendar');
        googleProvider.addScope('https://www.googleapis.com/auth/calendar.events');
        
        // Set custom parameters
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
          'login_hint': ''
        });

        // Try popup sign in
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile platform
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          throw 'Proses login dibatalkan';
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign In Error: $e');
      }
      throw _handleAuthError(e);
    }
  }

  Future<auth.AuthClient?> getGoogleAuthClient() async {
    try {
      return await _googleSignIn.authenticatedClient();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth client: $e');
      }
      return null;
    }
  }

  // Sign out
  Future<void> logout() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle auth exceptions
  String _handleAuthError(dynamic e) {
    if (kDebugMode) {
      print('Auth error: $e');
    }
    
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar';
        case 'wrong-password':
          return 'Password salah';
        case 'email-already-in-use':
          return 'Email sudah terdaftar';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'operation-not-allowed':
          return 'Operasi tidak diizinkan';
        case 'user-disabled':
          return 'Akun telah dinonaktifkan';
        case 'invalid-credential':
          return 'Kredensial tidak valid';
        case 'account-exists-with-different-credential':
          return 'Akun sudah ada dengan metode login yang berbeda';
        case 'network-request-failed':
          return 'Gagal terhubung ke server';
        case 'popup-closed-by-user':
          return 'Proses login dibatalkan';
        case 'redirect-cancelled-by-user':
          return 'Proses login dibatalkan';
        case 'redirect-failed':
          return 'Gagal melakukan redirect ke halaman login Google';
        default:
          return 'Terjadi kesalahan: ${e.message}';
      }
    }
    return e.toString();
  }
}
