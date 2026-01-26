import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/network/result.dart';

class FirebaseAuthService {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<Result<UserCredential?, Exception>> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return Failure(Exception('Google ile giriş iptal edildi.'));
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      return Success(userCredential);
    } catch (e) {
      print('Google ile girişte hata: $e');
      return Failure(Exception('Google ile girişte hata: $e'));
    }
  }

  Future<Result<void, Exception>> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return const Success(null);
    } catch (e) {
      print('Çıkış yapılırken hata: $e');
      return Failure(Exception('Çıkış yapılırken hata: $e'));
    }
  }
}
