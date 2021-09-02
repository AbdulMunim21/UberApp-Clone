import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uberapp_clone/main.dart';
import 'package:uberapp_clone/screens/registrationScreen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailCont = TextEditingController();

  TextEditingController _passCont = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailCont.dispose();
    _passCont.dispose();

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 65,
            ),
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Login as Rider",
              style: TextStyle(fontSize: 25),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCont,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.amber,
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      // style: TextStyle(color: Colors.green),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _passCont,
                      obscureText: true,

                      decoration: InputDecoration(
                        // helperStyle: TextStyle(color: Colors.amber),

                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      // style: TextStyle(color: Colors.green),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    isLoading
                        ? CircularProgressIndicator()
                        : ConstrainedBox(
                            constraints:
                                BoxConstraints.expand(width: 250, height: 40),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.amber,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                auth
                                    .signInWithEmailAndPassword(
                                        email: _emailCont.text,
                                        password: _passCont.text)
                                    .catchError((error) {
                                  Fluttertoast.showToast(
                                    msg: error.toString(),
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ;
                                }).then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an Account? "),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(RegistrationScreen.routeName);
                            },
                            child: Text(
                              'Signup Now',
                              style: TextStyle(color: Colors.amber),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
