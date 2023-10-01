import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> translations = [];

  // Function to fetch translations from Supabase
  Future<void> fetchTranslations() async {
    final response = await Supabase.instance.client.from('translator').select().execute();

    // Check if the response contains data
    if (response.data != null) {
      final List<dynamic> rawData = response.data as List<dynamic>;
      setState(() {
        // Map the raw data to a list of maps
        translations = rawData.map((dynamic item) {
          if (item is Map<String, dynamic> && item.containsKey('body')) {
            final formattedTranslation = item['body'] as String;
            final parts = formattedTranslation.split(' - ');
           // Check if the translation is valid
            if (parts.length == 2) {
              return <String, dynamic>{
                'originalText': parts[0],
                'translatedText': parts[1],
              };
            }
          }
          // If the translation is invalid, return an error message
          return <String, dynamic>{'originalText': 'Error', 'translatedText': 'Invalid data'};
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Call the function to fetch translations from Supabase
                fetchTranslations();
              },
              child: const Text('Get History'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: translations.length,
                itemBuilder: (context, index) {
                  final originalText = translations[index]['originalText'];
                  final translatedText = translations[index]['translatedText'];
                  return ListTile(
                    title: Text('$originalText - $translatedText'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


