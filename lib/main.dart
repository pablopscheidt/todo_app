import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Carrega as tarefas salvas do SharedPreferences
  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
      });
    }
  }

  // Salva as tarefas no SharedPreferences
  void _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(tasks));
  }

  // Adiciona uma nova tarefa
  void _addTask(Map<String, dynamic> task) {
    setState(() {
      tasks.add(task);
    });
    _saveTasks();
  }

  // Deleta uma tarefa
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    _saveTasks();
  }

  // Navega para a tela de detalhes
  void _navigateToDetails(BuildContext context, [int? index]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: index == null ? null : tasks[index],
          taskIndex: index,
        ),
      ),
    );
    if (result != null) {
      if (index != null) {
        setState(() {
          tasks[index] = result;
        });
      } else {
        _addTask(result);
      }
      _saveTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do List")),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              tasks[index]["title"],
              style: TextStyle(
                decoration: tasks[index]["isDone"]
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateToDetails(context, index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                ),
                Checkbox(
                  value: tasks[index]["isDone"],
                  onChanged: (bool? value) {
                    setState(() {
                      tasks[index]["isDone"] = value ?? false;
                    });
                    _saveTasks();
                  },
                ),
              ],
            ),
            onTap: () => _navigateToDetails(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToDetails(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? task;
  final int? taskIndex;

  const TaskDetailScreen({super.key, this.task, this.taskIndex});

  @override
  // ignore: library_private_types_in_public_api
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!["title"];
      descriptionController.text = widget.task!["description"] ?? "";
      dueDateController.text = widget.task!["dueDate"] ?? "";
    }
  }

  // Salva ou edita uma tarefa
  void _saveTask() {
    final task = {
      "title": titleController.text,
      "description": descriptionController.text,
      "dueDate": dueDateController.text,
      "isDone": false,
    };

    if (widget.taskIndex != null) {
      Navigator.pop(context, task);
    } else {
      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.taskIndex == null ? "Nova Tarefa" : "Editar Tarefa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descrição"),
              maxLines: 3,
            ),
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(labelText: "Prazo (dd/MM/yyyy)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text(widget.taskIndex == null
                  ? "Adicionar Tarefa"
                  : "Salvar Alterações"),
            ),
          ],
        ),
      ),
    );
  }
}
