// Import the necessary packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'history.dart';
import 'navigator_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qeoimipvamzaaucgkfbc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFlb2ltaXB2YW16YWF1Y2drZmJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU4NDQwNTgsImV4cCI6MjAxMTQyMDA1OH0.vqlRpU1tStZ7OthXSKsQrsyOH7nCMoaXdw26v4VH5s8', // Replace with your Supabase anonymous key
  );

  // Allow both portrait and landscape orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MaterialApp(
      title: 'Translation App',
      home: const TranslationScreen(),
      navigatorKey: NavigatorKeys.rootNavigatorKey,
    ),
  );
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController textEditingController = TextEditingController();
  String translatedText = '';
  final String apiKey = '519a068c-cd27-ab7c-c840-44b11ad9ab25:fx'; // Replace with your DeepL API key

  Future<void> translateText() async {
    final String textToTranslate = textEditingController.text;
    const String targetLanguage = 'SV'; // Swedish
    const String sourceLanguage = 'EN'; // English

    const String url =
        'https://api-free.deepl.com/v2/translate'; // Updated endpoint URL
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final Map<String, dynamic> body = {
      'text': textToTranslate,
      'source_lang': sourceLanguage,
      'target_lang': targetLanguage,
      'auth_key': apiKey,
    };

    final response =
    await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('translations') &&
            data['translations'].isNotEmpty) {
          setState(() {
            translatedText = data['translations'][0]['text'];
          });
        } else {
          setState(() {
            translatedText = 'Error: No translation data found';
          });
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        setState(() {
          translatedText = 'Error: Unable to translate text';
        });
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      print('DeepL API Error: ${errorData['message']}');
      setState(() {
        translatedText = 'Error: Unable to translate text';
      });
    }
  }

  Future<void> saveTranslationToSupabase(String translation) async {
    final response = await Supabase.instance.client.from('translator').upsert([
      {
        'body': translation,
      }
    ]).execute();
  }

  // Function to copy translated text to the clipboard
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $translatedText'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              NavigatorKeys.rootNavigatorKey.currentState?.push(
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter text to translate',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: translateText,
                child: const Text('Translate'),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Translated Text:',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Text(
                translatedText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  saveTranslationToSupabase(translatedText);
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: copyToClipboard,
                child: const Text('Copy to Clipboard'), // Add a "Copy to Clipboard" button
              ),
            ],
          ),
        ),
      ),
    );
  }
}








