import 'package:firebase_database/firebase_database.dart';

class Player {
    String key;
    String name;
    String last_name;
    String user_id;
    int level;

    Player(this.name, this.last_name, this.user_id, this.level);

    Player.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        user_id = snapshot.value['user_id'],
        name = snapshot.value['name'],
        last_name = snapshot.value['last_name'],
        level = snapshot.value['level'];

    toJson() {
        return {
            'user_id': user_id,
            'name': name,
            'last_name': last_name,
            'level': level
        };
    }
}