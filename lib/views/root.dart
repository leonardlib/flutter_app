import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth.dart';
import 'login_signup.dart';
import 'home.dart';

class Root extends StatefulWidget {
    Root({
        this.auth_service
    });

    final Auth auth_service;

    @override
    State<StatefulWidget> createState() => new RootState();
}

enum AuthStatus {
    NOT_DETERMINED,
    NOT_LOGGED_IN,
    LOGGED_IN,
}

class RootState extends State<Root> {
    AuthStatus auth_status = AuthStatus.NOT_DETERMINED;
    String user_id = "";

    @override
    void initState() {
        super.initState();
        widget.auth_service.getCurrentUser().then((user) {
            setState(() {
                if (user != null) {
                    user_id = user?.uid;
                }
                auth_status = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
            });
        });
    }

    void onLoggedIn() {
        widget.auth_service.getCurrentUser().then((user){
            setState(() {
                user_id = user.uid.toString();
            });
        });
        setState(() {
            auth_status = AuthStatus.LOGGED_IN;
        });
    }

    void onSignedOut() {
        setState(() {
            auth_status = AuthStatus.NOT_LOGGED_IN;
            user_id = "";
        });
    }

    Widget buildWaitingScreen() {
        return Scaffold(
            body: Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        switch (auth_status) {
            case AuthStatus.NOT_DETERMINED:
                return buildWaitingScreen();
                break;
            case AuthStatus.NOT_LOGGED_IN:
                return new LoginSignUp(
                    auth_service: widget.auth_service,
                    onSignedIn: onLoggedIn,
                );
                break;
            case AuthStatus.LOGGED_IN:
                if (user_id.length > 0 && user_id != null) {
                    return new Home(
                        user_id: user_id,
                        auth_service: widget.auth_service,
                        onSignedOut: onSignedOut,
                    );
                } else return buildWaitingScreen();
                break;
            default:
                return buildWaitingScreen();
        }
    }
}