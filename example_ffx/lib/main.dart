import 'package:flutter/material.dart';
import 'package:ffx/ffx.dart';
import 'ffx/fxw.dart';

import 'pages/main.dart';

// void main() {
//   // runApp(const MyApp());
//   runApp(f.MyFxApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: MainPage(),
//     );
//   }
// }

void main() => runApp(f.MyFxApp());

@FxWidget()
Widget _myFxApp() {
  return MaterialApp(
    title: 'FFx Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: f.HomePage(title: 'FFx Demo Home Page'),
  );
}

@FxWidget()
Widget _fxText(String data) {
  return Text(data);
}

@FxWidget()
Widget _homePage({required X x, required String title}) {
  final counter = x.remember(mutableStateOf(0));
  return Scaffold(
    appBar: f.AppBar(
      backgroundColor: x.theme.colorScheme.inversePrimary,
      title: Text(title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          f.FxText(
            'You have pushed the button this many times:',
            modifier: Modifior.textStyle(TextStyle(color: Colors.amber)),
          ),
          f.FxText(
            '${counter.value}',
            modifier: Modifior.paddingAll(12)
                .textStyle(TextStyle(color: Colors.green)),
            // style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        counter.value += 1;
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );
}
