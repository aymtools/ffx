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

class FirstPage extends XWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = x.remember(mutableIntStateOf(0));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: x.theme.colorScheme.inversePrimary,
        title: const Text('FFx Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
              style: x.theme.textTheme.headlineSmall,
            ),
            Text(
              '${counter.value}',
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
}
```

