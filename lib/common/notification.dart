import 'package:flutter/material.dart';
import 'dart:convert';
import './globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String apiToken = '', errMessage = '';
  late NotificationsData notificationsData;
  List itemsList = List.filled(0, null, growable: true);
  bool isLoaded = false;

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    notificationsData = await getNotifications();
    setState(() {
      isLoaded = true;
    });
  }

  Future<NotificationsData> getNotifications() async {
    final response =
        await http.get(Uri.https(globals.baseURL, "/api/get-my-notifications"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    });
    var resCode = response.statusCode;
    if (resCode == 200) {
      NotificationsData notificationsData = notificationsDataFromJson(response.body);
      itemsList = [...notificationsData.notifications];
      return notificationsData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return NotificationsData(
        message: 'Oops! Something went wrong.',
        notifications: [],
        unreadNotifications: [],
      );
    }
  }

  void markRead() async {
    final response =
        await http.get(Uri.https(globals.baseURL, "/api/mark-my-notifications-read"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiToken'
            });

    var data = jsonDecode(response.body);
    var resCode = response.statusCode;

    String message = data['message'];
    if (resCode == 200) {
      setState(() {
        
      });
      errorToast('Marked as read!!');
    } else {
      errorToast('$message !!');
    }
  }

  errorToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        webPosition: "center",
        webBgColor: "linear-gradient(to top, red, yellow)",
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const globals.AppBarItems('Notifications', '/'),
      body:  !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : (itemsList.isEmpty)
                  ? const Center(child: Text('No notifications found!!'))
                  : ListView.builder(
                      itemCount: itemsList.length+1,
                      itemBuilder: (context, index) => getItemsRow(index)),
    );
  }
  
  Widget getItemsRow(int index) {
    if (index < itemsList.length) {
      return Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child:ElevatedButton(
          onPressed: () { markRead(); },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(77, 182, 172, 1),)
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
              child: ListTile(
                title: Text('From: ${itemsList[index].user.firstName} ${itemsList[index].user.lastName}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                subtitle: Text(itemsList[index].message, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                trailing: Text(itemsList[index].createdAt),
              ),
          ),
        ),
      );
    }else{
      return const Padding(padding: EdgeInsets.only(bottom: 40));
    }
  }

}

NotificationsData notificationsDataFromJson(String str) => NotificationsData.fromJson(json.decode(str));

String notificationsDataToJson(NotificationsData data) => json.encode(data.toJson());

class NotificationsData {
    String message;
    List<Notification> notifications;
    List<Notification> unreadNotifications;

    NotificationsData({
        required this.message,
        required this.notifications,
        required this.unreadNotifications,
    });

    factory NotificationsData.fromJson(Map<String, dynamic> json) => NotificationsData(
        message: json["message"],
        notifications: List<Notification>.from(json["notifications"].map((x) => Notification.fromJson(x))),
        unreadNotifications: List<Notification>.from(json["unread_notifications"].map((x) => Notification.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
        "unread_notifications": List<dynamic>.from(unreadNotifications.map((x) => x.toJson())),
    };
}

class Notification {
    int id;
    String message;
    int from;
    int to;
    int isUnread;
    DateTime readAt;
    String createdAt;
    User user;

    Notification({
        required this.id,
        required this.message,
        required this.from,
        required this.to,
        required this.isUnread,
        required this.readAt,
        required this.createdAt,
        required this.user,
    });

    factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        message: json["message"],
        from: json["from"],
        to: json["to"],
        isUnread: json["is_unread"],
        readAt: DateTime.parse(json["read_at"]),
        createdAt: json["created_at"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "from": from,
        "to": to,
        "is_unread": isUnread,
        "read_at": readAt.toIso8601String(),
        "created_at": createdAt,
        "user": user.toJson(),
    };
}

class User {
    String firstName;
    String lastName;

    User({
        required this.firstName,
        required this.lastName,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        firstName: json["first_name"],
        lastName: json["last_name"],
    );

    Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
    };
}
