import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> translations = [];

  Future<void> fetchTranslations() async {
    final response = await Supabase.instance.client.from('translator').select().execute();

    if (response.data != null) {
      final List<dynamic> rawData = response.data as List<dynamic>;

      setState(() {
        translations = rawData.map((dynamic item) {
          if (item is Map<String, dynamic>) {
            return item as Map<String, dynamic>;
          } else {
            return <String, dynamic>{'body': 'Error: Invalid data'};
          }
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
              child: Text('Get History'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: translations.length,
                itemBuilder: (context, index) {
                  final translation = translations[index]['body'];
                  return ListTile(
                    title: Text(translation),
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
