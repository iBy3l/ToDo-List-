import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/page/widgets/TodoListItem.dart';
import 'package:lista_de_tarefas/repositories/todo_repository.dart';

import '../models/todo.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  //
  final TextEditingController todoContrller = TextEditingController();

  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xFFF61A69),
          title: Text(
            'Todo List',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Color(0xff0D0D0B),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoContrller,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: 'Adicionar Tarefa',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
/////////////////// Botão de Adicionar a tarefa na lista

                    ElevatedButton(
                      onPressed: () {
                        String text = todoContrller.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText =
                                'O campo de adicionar tarefa está vazio';
                          });
                          return;
                        }
                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          errorText = null;
                        });

                        todoContrller.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFF61A69),
                        fixedSize: Size(50, 55),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Você possui ${todos.length} Tarefas pendentes',
                        style: TextStyle(
                          color: Color(0xffFFFFFF),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmatDiealog,
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFF61A69),
                      ),
                      child: Text("Limpar tudo"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa \'${todo.title}\' foi removido com sucesso!',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xFFF61A69),
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
              todoRepository.saveTodoList(todos);
            });
          },
        ),
      ),
    );
  }

  void showDeleteTodosConfirmatDiealog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que quer apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Colors.black),
            child: Text(
              'Cancelar',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              deleteAlltodos();
            },
            style: TextButton.styleFrom(primary: Color(0xFFF61A69)),
            child: Text('Limapr Tudo'),
          ),
        ],
      ),
    );
  }

  void deleteAlltodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
