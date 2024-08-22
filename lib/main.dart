import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Supabase Demo',
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();
  final _notesStream = Supabase.instance.client.from('notes').stream(primaryKey: ['id']);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: _streamBuilder(),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  StreamBuilder<List<Map<String, dynamic>>> _streamBuilder() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _notesStream, 
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(),);
        }
        final notes = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text(notes[index]['text']),
                      SizedBox(width: 20),
                      Text(notes[index]['id'].toString()),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(notes[index]['created_at']),
                ),
              ],
            );
          }
        );
      }
    );
  }

  FloatingActionButton _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context, 
          builder: ((context) {
            return SimpleDialog(
              title: const Text('Add a Note'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                TextFormField(
                controller: controller,
  /* El texto que el usario ingresa en el TextForm es el value */
                onFieldSubmitted: (value) async {
                  await Supabase.instance.client
                    .from('notes')
                    .insert({'text': value });
  /* Limpiamos el TextFormField */                      
                  controller.clear();
                })
              ],
            );
          })
        );
      },
      child: const Icon(Icons.add),
    );
  }
}