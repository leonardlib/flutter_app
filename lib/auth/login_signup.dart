import 'package:flutter/material.dart';

class LoginSignup extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => new _LoginSignUpState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginSignUpState extends State<LoginSignup> {
    final _formKey = new GlobalKey<FormState>();
    String _email;
    String _password;
    String _errorMessage;

    // Initial form is login form
    FormMode _formMode = FormMode.LOGIN;
    bool _isIos;
    bool _isLoading;

    Widget _showCircularProgress() {
        if (_isLoading) {
            return Center(child: CircularProgressIndicator());
        }
        
        return Container(height: 0.0, width: 0.0);
    }
    
    Widget _showLogo() {
        return new Hero(
            tag: 'hero',
            child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
                child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 48.0,
                    child: Image.asset('assets/flutter-icon.png'),
                ),
            )
        );
    }
    
    Widget _showEmailInput() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: new InputDecoration(
                    hintText: 'Email',
                    icon: new Icon(
                        Icons.mail,
                        color: Colors.grey
                    )
                ),
                validator: (value) => value.isEmpty ? 'Email cant not be empty' : null,
                onSaved: (value) => _email = value,
            ),
        );
    }

    Widget _showPasswordInput() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
            child: new TextFormField(
                maxLines: 1,
                obscureText: true,
                autofocus: false,
                decoration: new InputDecoration(
                    hintText: 'Password',
                    icon: new Icon(
                        Icons.lock,
                        color: Colors.grey,
                    )
                ),
                validator: (value) => value.isEmpty ? 'Password cant not be empty' : null,
                onSaved: (value) => _password = value,
            ),
        );
    }

    Widget _showPrimaryButton() {
        return new Padding(
            padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
            child: new MaterialButton(
                elevation: 5.0,
                minWidth: 200.0,
                height: 42.0,
                color: Colors.blue,
                child: _formMode == FormMode.LOGIN
                    ? new Text('Login', style: new TextStyle(fontSize: 20.0, color: Colors.white))
                    : new Text('Create account',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)
                ),
                // onPressed: _validateAndSubmit,
            )
        );
    }

    Widget _showSecondaryButton() {
        return new FlatButton(
            child: _formMode == FormMode.LOGIN
                ? new Text('Create an account', style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
                : new Text('Have an account? Sign in',
                style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)
            ),
            // onPressed: _formMode == FormMode.LOGIN ? _changeFormToSignUp : _changeFormToLogin,
        );
    }

    Widget _showErrorMessage() {
        if (_errorMessage.length > 0 && _errorMessage != null) {
            return new Text(
                _errorMessage,
                style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.red,
                    height: 1.0,
                    fontWeight: FontWeight.w300
                ),
            );
        } else {
            return new Container(
                height: 0.0,
            );
        }
    }

    Widget _showBody(){
        return new Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
                key: _formKey,
                child: new ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                        _showLogo(),
                        _showEmailInput(),
                        _showPasswordInput(),
                        _showPrimaryButton(),
                        _showSecondaryButton(),
                        _showErrorMessage(),
                    ],
                ),
            )
        );
    }
    
    @override
    Widget build(BuildContext context) {
        _isIos = Theme.of(context).platform == TargetPlatform.iOS;

        return new Scaffold(
            appBar: new AppBar(
                title: new Text("Flutter login demo"),
            ),
            body: Stack(
                children: <Widget>[
                    _showBody(),
                    _showCircularProgress()
                ],
            ),
        );
    }

    @override
    void initState() {
        _errorMessage = "";
        _isLoading = false;
        super.initState();
    }
}