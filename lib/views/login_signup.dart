import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth.dart';

class LoginSignUp extends StatefulWidget {
    LoginSignUp({
        this.auth_service,
        this.onSignedIn
    });

    final Auth auth_service;
    final VoidCallback onSignedIn;

    @override
    State<StatefulWidget> createState() => new LoginSignUpState();
}

enum FormMode { LOGIN, SIGNUP }

class LoginSignUpState extends State<LoginSignUp> {
    final formKey = new GlobalKey<FormState>();

    String email;
    String password;
    String errorMessage;

    // Initial form is login form
    FormMode formMode = FormMode.LOGIN;
    bool isIos;
    bool isLoading;

    // Check if form is valid before perform login or signup
    bool validateAndSave() {
        final form = formKey.currentState;

        if (form.validate()) {
            form.save();
            return true;
        }

        return false;
    }

    // Perform login or signup
    void validateAndSubmit() async {
        setState(() {
            errorMessage = "";
            isLoading = true;
        });
        if (validateAndSave()) {
            String userId = "";
            try {
                if (formMode == FormMode.LOGIN) {
                    userId = await widget.auth_service.signIn(email, password);
                    print('Signed in: $userId');
                } else {
                    userId = await widget.auth_service.signUp(email, password);
                    widget.auth_service.sendEmailVerification();
                    showVerifyEmailSentDialog();
                    print('Signed up user: $userId');
                }
                setState(() {
                    isLoading = false;
                });

                if (userId != null && userId.length > 0 && formMode == FormMode.LOGIN) {
                    widget.onSignedIn();
                }

            } catch (e) {
                print('Error: $e');
                setState(() {
                    isLoading = false;

                    if (isIos) {
                        errorMessage = e.details;
                    } else
                        errorMessage = e.message;
                });
            }
        }
    }


    @override
    void initState() {
        errorMessage = "";
        isLoading = false;
        super.initState();
    }

    void changeFormToSignUp() {
        formKey.currentState.reset();
        errorMessage = "";
        setState(() {
            formMode = FormMode.SIGNUP;
        });
    }

    void changeFormToLogin() {
        formKey.currentState.reset();
        errorMessage = "";
        setState(() {
            formMode = FormMode.LOGIN;
        });
    }

    @override
    Widget build(BuildContext context) {
        isIos = Theme.of(context).platform == TargetPlatform.iOS;

        return new Scaffold(
            appBar: new AppBar(
                title: new Text('Flutter login demo'),
            ),
            body: Stack(
                children: <Widget>[
                    showBody(),
                    showCircularProgress(),
                ],
            )
        );
    }

    Widget showCircularProgress(){
        if (isLoading) {
            return Center(child: CircularProgressIndicator());
        } return Container(height: 0.0, width: 0.0,);
    }

    void showVerifyEmailSentDialog() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                    title: new Text("Verify your account"),
                    content: new Text("Link to verify account has been sent to your email"),
                    actions: <Widget>[
                        new FlatButton(
                            child: new Text("Dismiss"),
                            onPressed: () {
                                changeFormToLogin();
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    Widget showBody(){
        return new Container(
            margin: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
            child: new Form(
                key: formKey,
                child: new ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                        showLogo(),
                        showEmailInput(),
                        showPasswordInput(),
                        showPrimaryButton(),
                        showSecondaryButton(),
                        showErrorMessage(),
                    ],
                ),
            )
        );
    }

    Widget showErrorMessage() {
        if (errorMessage != null && errorMessage.length > 0) {
            return new Text(
                errorMessage,
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

    Widget showLogo() {
        return new Hero(
            tag: 'hero',
            child: FlutterLogo(size: 100.0),
        );
    }

    Widget showEmailInput() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 0.0),
            child: new TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: new InputDecoration(
                    hintText: 'Email',
                    icon: new Icon(
                        Icons.mail,
                        color: Colors.grey,
                    )
                ),
                validator: (value) {
                    if (value.isEmpty) {
                        setState(() {
                            isLoading = false;
                        });
                        return 'Email can\'t be empty';
                    }
                },
                onSaved: (value) => email = value,
            ),
        );
    }

    Widget showPasswordInput() {
        return Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 0.0),
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
                validator: (value) {
                    if (value.isEmpty) {
                        setState(() {
                            isLoading = false;
                        });
                        return 'Email can\'t be empty';
                    }
                },
                onSaved: (value) => password = value,
            ),
        );
    }

    Widget showSecondaryButton() {
        return new FlatButton(
            child: formMode == FormMode.LOGIN
                ? new Text('Create an account',
                style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
                : new Text('Have an account? Sign in',
                style:
                new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
            onPressed: formMode == FormMode.LOGIN
                ? changeFormToSignUp
                : changeFormToLogin,
        );
    }

    Widget showPrimaryButton() {
        return new Padding(
            padding: EdgeInsets.fromLTRB(50.0, 45.0, 50.0, 15.0),
            child: SizedBox(
                height: 50.0,
                child: new RaisedButton(
                    elevation: 10.0,
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blue,
                    child: formMode == FormMode.LOGIN
                        ? new Text('Login',
                        style: new TextStyle(fontSize: 20.0, color: Colors.white))
                        : new Text('Create account',
                        style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                    onPressed: validateAndSubmit,
                ),
            )
        );
    }
}