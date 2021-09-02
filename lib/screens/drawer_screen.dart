import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uberapp_clone/main.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String? profileName = null;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    String userUid = auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> user =
        await FirebaseFirestore.instance.collection('rider').doc(userUid).get();

    setState(() {
      profileName = user.data()!['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Container(
              child: Row(
                children: [
                  CircleAvatar(
                    maxRadius: 50,
                  ),
                  Column(
                    children: [
                      Text(profileName == null ? 'Profile Name' : profileName!),
                      TextButton(
                        child: Text(
                          "Visit Profile",
                          style: TextStyle(color: Colors.amber),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("History"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Visit Profile"),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("LogOut"),
              onTap: () {
                auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
