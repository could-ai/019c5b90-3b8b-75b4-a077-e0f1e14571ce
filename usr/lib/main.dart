import 'package:flutter/material.dart';
import 'screens/builder_screen.dart';
import 'widgets/resume_preview.dart';
import 'models/resume_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const BuilderScreen(),
        '/builder': (context) => const BuilderScreen(),
        // Preview route can be dynamic, but we register a placeholder or handle it via arguments if needed.
        // For simplicity in this structure, we push the preview directly from the builder, 
        // but we can register a route that accepts arguments if strictly required by the prompt's "On /preview" phrasing.
        '/preview': (context) => const Scaffold(body: Center(child: Text("Use the eye icon in Builder to preview"))),
      },
    );
  }
}
