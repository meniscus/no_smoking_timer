import 'package:flutter/material.dart';
import 'dart:async';
import 'util.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => TimerTickState()
      ),
    ],
    child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SmokingStatusWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}


class SmokingStatusWidget extends StatefulWidget {
  const SmokingStatusWidget({super.key});
  @override
  State<SmokingStatusWidget> createState() => _SmokingStatusState();
}

class SmokingSession {
  DateTime startAt;
  DateTime? endAt;
  int cigarettes;

  SmokingSession({
    required this.startAt,
    this.endAt,
    this.cigarettes = 1,
  });

  SmokingSession copyWith(
    {DateTime? startAt,DateTime? endAt,int? cigarettes,}
  ) => SmokingSession(
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    cigarettes: cigarettes ?? this.cigarettes
  );

  bool get isSmoking => endAt == null;
}

class _SmokingStatusState extends State<SmokingStatusWidget> {
  SmokingSession? currentSession;
  SmokingSession? lastSession;
  bool get isSmoking => currentSession?.isSmoking ?? false;

  void startSmoking() {
    setState(() {
      currentSession = SmokingSession(
        startAt: DateTime.now(),
        cigarettes: 1,
      );
    });
  }

  void endSmoking() async {
    final finished = currentSession!.copyWith(
      endAt: DateTime.now(),
    );

    // await repository.save(finished);

    setState(() {
      lastSession = finished;
      currentSession = null;
      
    });
  }

  void addCigarette() {
    if (currentSession == null) return;
    setState(() {
      currentSession!.cigarettes++;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _statusText(),
        _timerCount(context),
        // Spacer(),
        // TextField(),
        _getToggleButton(),
      ],
    );
  }

  Widget _statusText() {
    String getStatusText() {
      if (isSmoking) {
        return "喫煙中( ´ー｀)y-~~";
      } else {
        return "禁煙中( ･`ω･´)ｷﾘｯ";
      }
    }
    return Text(getStatusText());
  }

  Widget _timerCount(BuildContext context) {
    TimerTickState state = context.watch<TimerTickState>();
    String getElapsedTime() {
      if (isSmoking) {
        return "ごゆっくり";
      } else {
        if (lastSession == null) {
          // 初期状態
          return "--:--:--";
        } else {
          Duration elapsed = state.currentTime.difference(lastSession!.endAt!);
          return elapsed.toHMS();
        }
      }
    }
    return Text(getElapsedTime());
  }

  Widget _getToggleButton() {
    return ElevatedButton(
      onPressed: isSmoking ? endSmoking : startSmoking,
      child: Text(isSmoking ? "喫煙終了" : "喫煙開始"));
  }
}

class TimerTickState extends ChangeNotifier {
  Timer? _timer;
  DateTime currentTime = DateTime.now();

  TimerTickState() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), 
    (_){
      debugPrint("tick");
      currentTime = DateTime.now();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}