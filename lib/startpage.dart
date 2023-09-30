import 'package:flutter/material.dart';
import 'main.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Translation App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Translation App! \n\n'
                  'In this app, you can translate text from English to Swedish.\n'
                  'If you wish, you can also save important translations, which'
                  ' you can view later in the History tab.\n'
                  '\nTo get started, click the button below!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TranslationScreen(),
                ));
              },
              child: const Text('Start Translation'),
            ),
          ],
        ),
      ),
    );
  }
}
