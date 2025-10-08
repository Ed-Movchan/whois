import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(WhoisCheckerApp());

class WhoisCheckerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WhoisHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

class WhoisHomePage extends StatefulWidget {
  @override
  _WhoisHomePageState createState() => _WhoisHomePageState();
}

class _WhoisHomePageState extends State<WhoisHomePage> {
  final TextEditingController _controller = TextEditingController();
  final Dio _dio = Dio();

  String? _formattedResult;

  // Replace with your API key
  static const String apiKey = 'taP0KNAV7a8zF1qgpoX6FQEU9TyGWGyo';
  static const String apiUrl = 'https://api.apilayer.com/whois/query';

  Future<void> fetchWhois(String domain) async {
    final url = '$apiUrl?domain=$domain';

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'apikey': apiKey,
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data['result'];
        setState(() {
          _formattedResult = _formatWhoisData(data);
        });
      } else {
        setState(() {
          _formattedResult = 'Error: ${response.statusMessage}';
        });
      }
    } on DioException catch (e) {
      setState(() {
        _formattedResult = 'Error: ${e.response?.data ?? e.message}';
      });
    } catch (e) {
      setState(() {
        _formattedResult = 'An unexpected error occurred.';
      });
    }
  }

  String _formatWhoisData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _formatMap(data);
    }
    return 'Invalid data format.';
  }

  String _formatMap(Map<String, dynamic> map, [int indentLevel = 0]) {
    final StringBuffer buffer = StringBuffer();
    final String indent = '  ' * indentLevel;

    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        buffer.writeln('$indent$key: {');
        buffer.write(_formatMap(value, indentLevel + 1));
        buffer.writeln('$indent}');
      } else if (value is List) {
        buffer.writeln('$indent$key: [');
        value.forEach((item) {
          if (item is Map<String, dynamic>) {
            buffer.write(_formatMap(item, indentLevel + 1));
          } else {
            buffer.writeln('${'  ' * (indentLevel + 1)}$item,');
          }
        });
        buffer.writeln('$indent]');
      } else {
        buffer.writeln('$indent$key: $value,');
      }
    });

    return buffer.toString();
  }

  void _showSupportedTLDs() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supported TLDs'),
          content: SingleChildScrollView(
            child: Text(
              '''
TLDs currently supported are as follows:

.com .me .net .org .sh .io .co .club .biz .mobi .info .us .domains .cloud .fr .au .ru .uk .nl .fi .br .hr .ee .ca .sk .se .no .cz .it .in .icu .top .xyz .cn .cf .hk .sg .pt .site .kz .si .ae .do .yoga .xxx .ws .work .wiki .watch .wtf .world .website .vip .ly .dev .network .company .page .rs .run .science .sex .shop .solutions .so .studio .style .tech .travel .vc .pub .pro .app .press .ooo .de
              ''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _clearInput() {
    _controller.clear();
    setState(() {
      _formattedResult = null; // Clear any displayed results as well
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WHOIS Checker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Enter domain',
                      border: OutlineInputBorder(),
                    ),

                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _clearInput,
                  icon: Icon(Icons.clear),
                  tooltip: 'Clear input',
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchWhois(_controller.text);
                }
              },
              child: Text('Check WHOIS'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _formattedResult == null
                  ? Center(child: Text('Enter a domain to get WHOIS data.'))
                  : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _formattedResult!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSupportedTLDs,
        child: Icon(Icons.info),
      ),
    );
  }
}
