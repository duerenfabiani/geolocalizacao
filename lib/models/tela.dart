import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:tdm20212/models/localizacao.dart';

class LocalizacaoTela extends StatefulWidget {
  @override
  _LocalizacaoTelaState createState() => _LocalizacaoTelaState();
}

class _LocalizacaoTelaState extends State<LocalizacaoTela> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference _localizacao =
      FirebaseFirestore.instance.collection('localizacao');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Listagem'),
          elevation: 0,
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _localizacao.orderBy('user').snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data!.docs.reversed.toList();
                  return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return Localizacao(
                            documents[index],
                            documents[index].get('uid') == _currentUser?.uid,
                            _scaffoldKey);
                      });
              }
            },
          )),
          _isLoading ? LinearProgressIndicator() : Container()
        ]));
  }

  Future<User?> _getUser({required BuildContext context}) async {
    User? user;

    if (_currentUser != null) return _currentUser;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (err) {
        print(err);
      }
    } else {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;
        } on FirebaseAuthException catch (err) {
          print(err);
        } catch (err) {
          print(err);
        }
      }
    }

    return user;
  }

  void _enviaLocalizacao({String? text}) async {
    final CollectionReference _localizacao =
        FirebaseFirestore.instance.collection('localizacao');

    User? user = await _getUser(context: context);

    if (user == null) {
      const snackBar =
          SnackBar(content: Text('Login Falhou'), backgroundColor: Colors.red);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Map<String, dynamic> data = {'localizacao': '', 'user': user?.displayName};

    String userId = '';
    if (user != null) userId = user.uid;

    _localizacao.add(data);
  }
}
