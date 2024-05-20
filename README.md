ffx is a brand new life cycle + state management tool in flutter. It is intended to solve the
templating problem written by StatefulWidget, simplify the code, and improve work efficiency.

## Reason:

There are too many template codes when writing StatefulWidget, as well as state update exceptions
and context switching that occur with StreamBuilder. At the same time, inspired by Compose, we try
to reduce template code as much as possible during the development process.

## Usage

Customize your Widget and extend XWidget, then in build() you will get an x, x provides everything
you are familiar with
x.remember
x.find

```dart
void main() => runApp(f.MyFxApp());

@Fx()
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

@Fx()
Widget _fxText(String data) {
  return Text(data);
}

@Fx()
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
```

