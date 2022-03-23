import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tdm20212/models/tela.dart';
import 'package:tdm20212/models/mapa.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCV7Evqjlp3hOo26NdEvkfyxyXCF-Qwkeg",
            appId: "1:998511716485:web:9c619f256471f03a24e1ec",
            authDomain: "tdm20212-c63df.firebaseapp.com",
            messagingSenderId: "998511716485",
            projectId: "tdm20212-c63df",
            storageBucket: "tdm20212-c63df.appspot.com"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Localização',
        theme: ThemeData.dark(),
        home: NavigationOptions());
  }
}

class NavigationOptions extends StatefulWidget {
  @override
  State<NavigationOptions> createState() => _NavigationOptionsState();
}

class _NavigationOptionsState extends State<NavigationOptions> {
  int _page = 1;
  PageController? pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: _page);
  }

  setPage(page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [LocalizacaoTela(), MapClick()],
        onPageChanged: setPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listagem'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Mapa'),
        ],
        onTap: (page) {
          pc?.animateToPage(page,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
        backgroundColor: Color.fromARGB(255, 27, 27, 27),
      ),
    );
  }
}
