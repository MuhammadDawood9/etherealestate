import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with Email and Password
  Future<({User user, bool isNewAccount})> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user!;
      // Send verification email in the background — don't block access
      if (!user.emailVerified) {
        user.sendEmailVerification();
      }
      return (user: user, isNewAccount: true);
    } catch (e) {
      if (kDebugMode) debugPrint('Registration Error: ${e.toString()}');
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      if (kDebugMode) debugPrint('Sign In Error: ${e.toString()}');
      rethrow;
    }
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use Firebase Auth popup — google_sign_in package needs a native client
        // ID on web which requires extra setup; signInWithPopup works out of the box.
        final provider = GoogleAuthProvider();
        final result = await _auth.signInWithPopup(provider);
        return result.user;
      }

      // Mobile flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      if (kDebugMode) debugPrint('Google Sign-In Error: ${e.toString()}');
      rethrow;
    }
  }

  // Sign out from all providers
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  // Update user profile (display name)
  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(name ?? user.displayName);
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
  }
}
