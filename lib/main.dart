import 'package:bakingconverter/pages/ConversionScreen.dart';
import 'package:bakingconverter/pages/CupCovScreen.dart';
import 'package:bakingconverter/pages/TemperatureScreen.dart';
import 'package:bakingconverter/util/Converters.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TemperatureConverter.init();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.montserratTextTheme(
          const TextTheme(
            bodyText1: TextStyle(fontSize: 20.0),
            bodyText2: TextStyle(fontSize: 30.0),
            headline5: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Baking Converter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late PageController _tabController;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int _flagIgnore = 0;
  int _lastPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void pageChanged(int index) {
    _lastPage = index;
    if (_flagIgnore > 0) {
      _flagIgnore--;
    } else {
      final CurvedNavigationBarState? navBarState =
          _bottomNavigationKey.currentState;
      navBarState?.setPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
            centerTitle: true,
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: PopupMenuButton(
                    child: const Icon(Icons.settings),
                    itemBuilder: (context) => [
                          const PopupMenuItem(
                            child: Text("Remove ads"),
                            value: 1,
                          ),
                          const PopupMenuItem(
                            child: Text("Send feedback"),
                            value: 2,
                          ),
                          const PopupMenuItem(
                            child: Text("Reset ingredients"),
                            value: 3,
                          ),
                        ]),
              )
            ],
          ),
          body: PageView(
            children: const [
              TempConverterPage(),
              UnitConverterPage(),
              CupConverterPage()
            ],
            controller: _tabController,
            onPageChanged: pageChanged,
          ),
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            color: Colors.blue,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            animationDuration: const Duration(milliseconds: 400),
            items: const <Widget>[
              Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.list,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.compare_arrows,
                size: 30,
                color: Colors.white,
              ),
            ],
            onTap: (index) {
              if (_flagIgnore > 0) return;
              if (_lastPage == index) return;
              _flagIgnore++;
              if (_lastPage - index == 2 || _lastPage - index == -2) {
                _flagIgnore++;
              }
              _tabController.animateToPage(index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease);
            },
          ),
        ),
      ),
    );
  }
}
