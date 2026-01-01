import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: '禁煙タイマー'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SmokingStatusWidget(),
          ],
        ),
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
  final List<SmokingSession> sessions = [];

  bool get isSmoking => currentSession?.isSmoking ?? false;
  SmokingSession? get lastSession => sessions.isNotEmpty ? sessions.last : null;
  int get totalCigarettes => sessions.fold(0, (sum, s) => sum + s.cigarettes);

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
    debugPrint("finished: ${finished}");

    setState(() {
      sessions.add(finished);
      currentSession = null;
      
    });
  }

  void changeCigarette(int delta) {
    if (currentSession == null) return;
    setState(() {
      final next = currentSession!.cigarettes + delta;
      if (next >= 1) {
        currentSession = currentSession!.copyWith(
          cigarettes: max(1, currentSession!.cigarettes + delta),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _statusText(),
        _timerCount(context),
        const Divider(),
        Center(child: _getSpinButton()),
        _getToggleButton(),
        const Divider(),
        Text("今日の合計：$totalCigarettes 本"),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: _sessionHistory(),
        )
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

  Widget _getSpinButton() {
    return SpinButton(
      value: currentSession?.cigarettes ?? 1,
      onIncrement: () =>changeCigarette(1),
      onDecrement: () => changeCigarette(-1),
    );
  }


  Widget _getToggleButton() {
    return ElevatedButton(
      onPressed: isSmoking ? endSmoking : startSmoking,
      child: Text(isSmoking ? "喫煙終了" : "喫煙開始"));
  }


  Widget _sessionHistory() {
    if (sessions.isEmpty) {
      return const Text("まだ記録がありません");
    }

    return ListView.builder(
      // shrinkWrap: true,
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];
        return ListTile(
          leading: const Icon(Icons.smoking_rooms),
          title: Text("${s.cigarettes} 本"),
          subtitle: Text(
            "${s.startAt} - ${s.endAt!}", // TODO format
          ),
          trailing: Text(
            s.endAt!
            .difference(s.startAt)
            .inMinutes
            .toString() + "分",
          ),
        );
      },
    );
  }
}



class TimerTickState extends ChangeNotifier {
  Timer? _timer;
  DateTime currentTime = DateTime.now();

  TimerTickState() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), 
    (_){
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



