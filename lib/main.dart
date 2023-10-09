import 'package:flutter/material.dart';
import 'package:life_counter/life_event.dart';
import 'objectbox.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LifeCounterPage(),
    );
  }
}

class LifeCounterPage extends StatefulWidget {
  const LifeCounterPage({super.key});

  @override
  State<LifeCounterPage> createState() => _LifeCounterPageState();
}

class _LifeCounterPageState extends State<LifeCounterPage> {
  Store? store;
  Box<LifeEvent>? lifeEventBox;
  List<LifeEvent> lifeEvents = [];

  Future<void> initialize() async {
    store = await openStore();
    lifeEventBox = store?.box<LifeEvent>();
    fetchLifeEvents();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void fetchLifeEvents() {
    lifeEvents = lifeEventBox?.getAll() ?? [];
    setState(() {});
  }

  void deleteAllLifeEvents() {
    lifeEventBox?.removeAll();
    fetchLifeEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('人生カウンター'),
        ),
        body: ListView.builder(
          itemCount: lifeEvents.length,
          itemBuilder: (context, index) {
            final lifeEvent = lifeEvents[index];
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    lifeEvent.title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  )),
                  Text(
                    '${lifeEvent.count}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      lifeEvent.count++;
                      lifeEventBox?.put(lifeEvent);
                      fetchLifeEvents();
                    },
                    icon: const Icon(Icons.plus_one),
                  ),
                  IconButton(
                    onPressed: () {
                      lifeEvent.count--;
                      lifeEventBox?.put(lifeEvent);
                      fetchLifeEvents();
                    },
                    icon: const Icon(Icons.exposure_minus_1),
                  ),
                  IconButton(
                    onPressed: () {
                      lifeEventBox?.remove(lifeEvent.id);
                      fetchLifeEvents();
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  final newLifeEvent =
                      await Navigator.of(context).push<LifeEvent>(
                    MaterialPageRoute(
                      builder: (context) {
                        return const AddLifeEventPage();
                      },
                    ),
                  );
                  if (newLifeEvent != null) {
                    lifeEventBox?.put(newLifeEvent);
                    fetchLifeEvents();
                  }
                }),
            const SizedBox(height: 16),
            FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () {
                  deleteAllLifeEvents();
                },
                child: const Icon(Icons.delete))
          ],
        ));
  }
}

class AddLifeEventPage extends StatefulWidget {
  const AddLifeEventPage({super.key});

  @override
  State<AddLifeEventPage> createState() => _AddLifeEventPageState();
}

class _AddLifeEventPageState extends State<AddLifeEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ライフイベント追加'),
      ),
      body: TextFormField(
        onFieldSubmitted: (text) {
          final lifeEvent = LifeEvent(title: text, count: 0);
          Navigator.of(context).pop(lifeEvent);
        },
      ),
    );
  }
}
