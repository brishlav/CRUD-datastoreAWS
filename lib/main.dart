import 'package:flutter/material.dart';
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';
import 'models/PatModel.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart'; // Import Amplify API

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    final dataStorePlugin = AmplifyDataStore(modelProvider: ModelProvider.instance);
    final apiPlugin = AmplifyAPI(); // Create an instance of AmplifyAPI

    try {
      Amplify.addPlugins([dataStorePlugin, apiPlugin]); // Add both plugins
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
      print('Amplify successfully configured');
    } catch (e) {
      print('Failed to configure Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify DataStore Demo',
      home: _amplifyConfigured ? HomePage() : CircularProgressIndicator(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PatModel> _models = [];

  @override
  void initState() {
    super.initState();
    fetchModels();
  }

  Future<void> fetchModels() async {
    try {
      final models = await Amplify.DataStore.query(PatModel.classType);
      setState(() {
        _models = models;
      });
    } catch (e) {
      print('Failed to fetch models: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amplify DataStore'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _models.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_models[index].data),
                  subtitle: Text('ID: ${_models[index].id}'),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => create(),
                child: Text('Create'),
              ),
              ElevatedButton(
                onPressed: () => update(),
                child: Text('Update'),
              ),
              ElevatedButton(
                onPressed: () => delete(),
                child: Text('Delete'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void create() async {
    final newModel = PatModel(id: DateTime.now().toString(), data: "Data at ${DateTime.now()}");
    try {
      await Amplify.DataStore.save(newModel);
      fetchModels();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PatModel created')));
    } catch (e) {
      print('Failed to create model: $e');
    }
  }

  void update() async {
    if (_models.isNotEmpty) {
      final model = _models.first;
      final updatedModel = model.copyWith(data: model.data + ' [UPDATED]');
      try {
        await Amplify.DataStore.save(updatedModel);
        fetchModels();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PatModel updated')));
      } catch (e) {
        print('Failed to update model: $e');
      }
    }
  }

  void delete() async {
    if (_models.isNotEmpty) {
      try {
        await Amplify.DataStore.delete(_models.first);
        fetchModels();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PatModel deleted')));
      } catch (e) {
        print('Failed to delete model: $e');
      }
    }
  }
}
