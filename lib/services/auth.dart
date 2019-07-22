import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
    Future<String> signIn(String email, String password);
    Future<String> signUp(String email, String password);
    Future<FirebaseUser> getCurrentUser();
    Future<void> sendEmailVerification();
    Future<void> signOut();
    Future<bool> isEmailVerified();
}

class Auth implements AuthService {
    final FirebaseAuth firebase_auth = FirebaseAuth.instance;

    Future<String> signIn(String email, String password) async {
        FirebaseUser user = await firebase_auth.signInWithEmailAndPassword(
                email: email, password: password);
        return user.uid;
    }

    Future<String> signUp(String email, String password) async {
        FirebaseUser user = await firebase_auth.createUserWithEmailAndPassword(
                email: email, password: password);
        return user.uid;
    }

    Future<FirebaseUser> getCurrentUser() async {
        FirebaseUser user = await firebase_auth.currentUser();
        return user;
    }

    Future<void> signOut() async {
        return firebase_auth.signOut();
    }

    Future<void> sendEmailVerification() async {
        FirebaseUser user = await firebase_auth.currentUser();
        user.sendEmailVerification();
    }

    Future<bool> isEmailVerified() async {
        FirebaseUser user = await firebase_auth.currentUser();
        return user.isEmailVerified;
    }

}