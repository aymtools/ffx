import 'package:ffx/ffx.dart';
import 'package:flutter/material.dart';

import 'package:example_ffx/ffx/fxw.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return f.MainPageContent(title: 'Flutter Demo Home Page');
  }
}

// @Fx()
// Widget _mainPage() {
//   return MainPageContent(title: 'Flutter Demo Home Page');
// }

@Fx()
Widget _mainPageContent({required X x, required String title}) {
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
          f.SimpleText(
            text: 'You have pushed the button this many times:',
            modifier: Modifior.textStyle(
              TextStyle(color: Colors.amber),
            ),
          ),
          f.SimpleText(
            text: '${counter.value}',
            modifier: Modifior.paddingAll(12).textStyle(
              TextStyle(color: Colors.green),
            ),
            // style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        counter.value = counter.value + 1;
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );
}

@Fx()
Widget _simpleText({required X x, required String text, int? fontSize}) {
  return Text(text);
}
