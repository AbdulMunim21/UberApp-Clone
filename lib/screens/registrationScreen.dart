import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uberapp_clone/main.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = 'registration-screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _nameCont = TextEditingController();

  TextEditingController _emailCont = TextEditingController();

  TextEditingController _phoneCont = TextEditingController();

  TextEditingController _passCont = TextEditingController();

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCont.dispose();
    _passCont.dispose();
    _phoneCont.dispose();
    _nameCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
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
              Text(
                "Register as Rider",
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.length < 0 || value.length > 20) {
                          return "Name must be greater than 0 and less than 20";
                        }
                        return null;
                      },
                      controller: _nameCont,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                      validator: (value) {
                        if (value!.length < 0 || value.length > 20) {
                          return "Email must be greater than 0 and less than 20";
                        } else if (!value.contains("@")) {
                          return "Please Follow email Syntax by adding @";
                        }
                        return null;
                      },
                      controller: _emailCont,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
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
                      validator: (value) {
                        if (value!.length < 0 || value.length > 13) {
                          return "PhoneNumber must be greater than 0 and less than 11";
                        } else if (!value.contains("+92")) {
                          return "Phone Number must have country code e.g. +92";
                        }
                        return null;
                      },
                      controller: _phoneCont,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
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
                      validator: (value) {
                        if (value!.length < 6) {
                          return "Password must be greater than 6 letters";
                        }
                        return null;
                      },
                      controller: _passCont,
                      obscureText: true,
                      decoration: InputDecoration(
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
                    ConstrainedBox(
                      constraints:
                          BoxConstraints.expand(width: 250, height: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () async {
                          bool isValidate = _formkey.currentState!.validate();
                          if (!isValidate) {
                            return null;
                          }
                          await auth
                              .createUserWithEmailAndPassword(
                                  email: _emailCont.text,
                                  password: _passCont.text)
                              .then((value) async {
                            if (value != null) {
                              await riderRef.doc(value.user!.uid).set({
                                'name': _nameCont.text,
                                'email': _emailCont.text,
                                'phone': _phoneCont.text,
                                'id': value.user!.uid,
                              });
                            }
                          });
                        },
                        child: Text(
                          "Create Account",
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
                        Text("Already have an Account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'SignIn Now',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
