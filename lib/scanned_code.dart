import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannedCodesPage extends StatefulWidget {
  final List<String> lastScannedCodes;

  const ScannedCodesPage({Key? key, required this.lastScannedCodes})
      : super(key: key);

  @override
  State<ScannedCodesPage> createState() => _ScannedCodesPageState();
}

class _ScannedCodesPageState extends State<ScannedCodesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Son Tarama Sonuçları',
          style:
              TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.deepPurple,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.lastScannedCodes.length,
        itemBuilder: (context, index) {
          final code = widget.lastScannedCodes[index];
          return Dismissible(
            key: Key(code),
            onDismissed: (direction) {
              setState(() {
                widget.lastScannedCodes.removeAt(index);
              });
              _saveLastScannedCodes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sonuç Silindi')),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16.0),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.link),
              title: Text(code),
              onTap: () async {
                if (Uri.parse(code).isAbsolute) {
                  await _launchURL(context, code);
                }
              },
              trailing: IconButton(
                onPressed: () {
                  setState(() {
                    widget.lastScannedCodes.removeAt(index);
                  });
                  _saveLastScannedCodes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sonuç Silindi')),
                  );
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      await launch(url, forceSafariVC: false);
    } catch (e) {
      await launch(url, forceSafariVC: true);
    }
  }

  Future<void> _saveLastScannedCodes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('lastScannedCodes', widget.lastScannedCodes);
  }
}
