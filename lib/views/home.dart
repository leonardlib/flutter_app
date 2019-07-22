import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_app/services/auth.dart';

class Home extends StatefulWidget {
    Home({
        Key key,
        this.auth_service,
        this.user_id,
        this.onSignedOut,
    }) : super(key: key);

    final Auth auth_service;
    final VoidCallback onSignedOut;
    final String user_id;

    @override
    State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<Home> {
    List<Player> players;
    final FirebaseDatabase database = FirebaseDatabase.instance;
    final GlobalKey<FormState> form_key = GlobalKey<FormState>();
    final textEditingController = TextEditingController();
    StreamSubscription<Event> on_player_added_subscription;
    StreamSubscription<Event> on_player_changed_subscription;
    Query player_query;
    bool is_email_verified = false;

    @override
    void initState() {
        super.initState();

        checkEmailVerification();

        players = new List();
        player_query = database.reference()
            .child('player')
            .orderByChild('user_id')
            .equalTo(widget.user_id);

        on_player_added_subscription = player_query.onChildAdded.listen(onPlayerAdded);
        on_player_changed_subscription = player_query.onChildChanged.listen(onPlayerChanged);
    }

    void checkEmailVerification() async {
        is_email_verified = await widget.auth_service.isEmailVerified();

        if (!is_email_verified) {
            showVerifyEmailDialog();
        }
    }

    void resentVerifyEmail() {
        widget.auth_service.sendEmailVerification();
        showVerifyEmailSentDialog();
    }

    void showVerifyEmailDialog() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: new Text('Verify your account'),
                    content: new Text('Please verify account in your inbox mail'),
                    actions: <Widget>[
                        new FlatButton(
                            child: new Text('Resent link'),
                            onPressed: () {
                                Navigator.of(context).pop();
                                resentVerifyEmail();
                            }
                        ),
                        new FlatButton(
                            child: new Text('Dismiss'),
                            onPressed: () {
                                Navigator.of(context).pop();
                            }
                        )
                    ],
                );
            }
        );
    }

    void showVerifyEmailSentDialog() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: new Text('Verify your account'),
                    content: new Text('Link to verify account has been sent to your email'),
                    actions: <Widget>[
                        new FlatButton(
                            child: new Text('Dismiss'),
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                        )
                    ],
                );
            }
        );
    }

    @override
    void dispose() {
        on_player_added_subscription.cancel();
        on_player_changed_subscription.cancel();
        super.dispose();
    }

    onPlayerAdded(Event event) {
        setState(() {
            players.add(Player.fromSnapshot(event.snapshot));
        });
    }

    onPlayerChanged(Event event) {
        var old_player = players.singleWhere((player) {
            return player.key == event.snapshot.key;
        });

        setState(() {
            players[players.indexOf(old_player)] = Player.fromSnapshot(event.snapshot);
        });
    }

    signOut() async {
        try {
            await widget.auth_service.signOut();
            widget.onSignedOut();
        } catch (e) {
            print(e);
        }
    }

    addNewPlayer(Player player) {
        database.reference().child('player').push().set(player.toJson());
    }

    updatePlayer(Player player) {
        database.reference().child('player').child(player.key).set(player.toJson());
    }

    deletePlayer(String player_key, int index) {
        database.reference().child('player').child(player_key).remove().then((_) {
            setState(() {
                players.removeAt(index);
            });
        });
    }

    showAnotherDialog(BuildContext context) async {
        textEditingController.clear();

        await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    content: new Row(
                        children: <Widget>[
                            new Expanded(
                                child: new TextField(
                                    controller: textEditingController,
                                    autofocus: true,
                                    decoration: new InputDecoration(
                                        labelText: 'Add new player'
                                    ),
                                ),
                            )
                        ],
                    ),
                    actions: <Widget>[
                        new FlatButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                                Navigator.pop(context);
                            },
                        ),
                        new FlatButton(
                            child: const Text('Save'),
                            onPressed: () {
                                // addNewPlayer(textEditingController.text.toString());
                                Navigator.pop(context);
                            },
                        )
                    ],
                );
            }
        );
    }

    Widget showPlayersList() {
        if (players.length > 0) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (BuildContext context, int index) {
                    String player_key = players[index].key;
                    String name = players[index].name;
                    String last_name = players[index].last_name;
                    String user_id = players[index].user_id;
                    int level = players[index].level;

                    return Dismissible(
                        key: Key(player_key),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) async {
                            deletePlayer(player_key, index);
                        },
                        child: ListTile(
                            title: Text(
                                name,
                                style: TextStyle(fontSize: 20.0),
                            )
                        ),
                    );
                },
            );
        } else {
            return Center(
                child: Text(
                    'Welcome, Your list is empty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0),
                )
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('Flutter login demo'),
                actions: <Widget>[
                    new FlatButton(
                        child: new Text(
                            'Logout',
                            style: new TextStyle(fontSize: 17.0, color: Colors.white)
                        ),
                        onPressed: signOut)
                ],
            ),
            body: showPlayersList(),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    showAnotherDialog(context);
                },
                tooltip: 'Increment',
                child: Icon(Icons.add),
            )
        );
    }
}