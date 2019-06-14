import 'package:flutter/material.dart';
import 'package:flutter_app/auth/login_signup.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Flutter App',
            theme: new ThemeData(
                primarySwatch: Colors.blue
            ),
            home: new LoginSignup(),
        );
    }
}
