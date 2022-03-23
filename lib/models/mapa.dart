import 'dart:collection';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

abstract class GoogleMapAppPage extends StatelessWidget {
  const GoogleMapAppPage(this.leading, this.title);

  final Widget leading;
  final String title;
}

//carrega posição inicial
const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(-28.474316593209863, -51.84470452427857), zoom: 16.0);

//marcador quando o mapa é clicado
class MapClick extends StatefulWidget {
  const MapClick();

  @override
  State<StatefulWidget> createState() => MapClickState();
}

class MapClickState extends State<MapClick> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? _currentUser;

  MapClickState();

  GoogleMapController? mapController;
  LatLng? _Local;
  final _textController = TextEditingController();
  bool _isComposing = false;

  /*Set<Marker> _markers = HashSet<Marker>();
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;
*/
  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      //markers: _markers,
      onTap: (LatLng pos) {
        setState(() {
          _Local = pos;
        });
      },
    );
//column latlng tela mapa
    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width,
            child: googleMap,
          ),
        ),
      ),
    ];
//text latlng tela mapa
    if (mapController != null) {
      columnChildren.add(Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Text('$_Local',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Color.fromARGB(255, 194, 194, 194),
              ))));
//column localizacaoName
      columnChildren.add(SizedBox(
          width: MediaQuery.of(context).size.width * .1,
          child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    decoration: new InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 15,
                          bottom: 11,
                          top: 11,
                          right: 15,
                        ),
                        hintText: "Nome do local"),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.length > 0;
                      });
                    },
                    onSubmitted: (text) {
                      _reset();
                    },
                  )),
                  //icon pra add
                  IconButton(
                    icon: Icon(
                      Icons.add_box_rounded,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: (_Local != null && _isComposing)
                        ? () {
                            _enviaLocalizacao();
                          }
                        : null,
                  )
                ],
              ))));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController = controller;
    });
  }

//reset chama dps
  void _reset() {
    setState(() {
      _textController.text = '';
      _Local = null;
    });
  }

//auth google
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

//envia localização
  void _enviaLocalizacao() async {
    final CollectionReference _localizacao =
        FirebaseFirestore.instance.collection('localizacao');

    User? user = await _getUser(context: context);

    Map<String, dynamic> data = {
      'localizacao': new GeoPoint(_Local!.longitude, _Local!.latitude),
      'localizacaoName': _textController.text,
      'uid': user?.uid,
      'user': user?.displayName
    };

    String userId = '';
    if (user != null && _Local != null) {
      userId = user.uid;
      _reset();
    }
    /*final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    LatLng point =
        new LatLng();
    _markers.add(Marker(
      markerId: MarkerId(markerIdVal),
      position: point,
    ));
    setState(() {});
    */
    _localizacao.add(data);
  }
}
