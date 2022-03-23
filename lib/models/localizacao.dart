import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Localizacao extends StatelessWidget {
  Localizacao(this.data, this.mine, this.scaffoldKey);

  final DocumentSnapshot<Object?> data;
  final bool mine;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  //listageem SCRENN
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Localização: ' + data.get('localizacaoName'),
                style: TextStyle(fontSize: 20),
              ),
              Text(
                  //get pra mostra os dados banco
                  'latlng: ' +
                      data.get('localizacao').latitude.toString() +
                      ' ' +
                      data.get('localizacao').longitude.toString(),
                  style: TextStyle(fontSize: 14)),
              Text(
                data.get('user'),
              )
            ],
          )),
        ],
      ),
    );
  }
}
