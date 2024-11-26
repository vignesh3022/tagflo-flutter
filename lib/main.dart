import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _enteredText = '';
  int _tagCount = 0;
  static const platform = MethodChannel('com.example.tagflo_flutter/scanner');
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      // Initialize scanner through platform channel
      await platform.invokeMethod('initializeScanner');
      // Set up scanner callback
      platform.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onScanComplete':
            final String scannedCode = call.arguments['barcode'] as String;
            setState(() {
              _enteredText += scannedCode + '\n';
              _tagCount++;
            });
            break;
        }
      });
    } catch (e) {
      print('Error initializing scanner: $e');
    }
  }

  @override
  void dispose() {
    // Clean up scanner resources
    platform.invokeMethod('disposeScanner');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Tag count display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tags Scanned: $_tagCount',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Scanned tags display
            Expanded(
              child: TextField(
                controller: TextEditingController(text: _enteredText),
                maxLines: null,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Scanned Tags',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
