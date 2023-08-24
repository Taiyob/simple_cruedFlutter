import 'package:crued_operation/screen/add_page.dart';
import 'package:crued_operation/services/todo_service.dart';
import 'package:crued_operation/widget/todo_card.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar_helper.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);
  @override
  State<TodoList> createState() => _TodoListState();
}
class _TodoListState extends State<TodoList> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Center(child: Text('Todo List')),
       ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator(),),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text('No to do Item', style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          child: ListView.builder(itemCount: items.length,padding:EdgeInsets.all(12),itemBuilder: (context,index){
             final item = items[index] as Map;
             final id = item['_id'] as String;
             return TodoCard(
                 index: index,
                 deleteById: deleteById,
                 navigateEdit: navigateToEditPage,
                 item: item
             );
          }),
        ),
      ),
    ),
      floatingActionButton: FloatingActionButton.extended
        (onPressed: navigateToAddPage, label: Text('Add Todo')),
    );
  }
  Future<void> navigateToEditPage (Map item) async{
    final route = MaterialPageRoute(builder: (context)=> AddTodoPage(todo:item),);
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
  Future<void> navigateToAddPage () async{
    final route = MaterialPageRoute(builder: (context)=> AddTodoPage(),);
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);
    if(isSuccess){
       final filtered = items.where((element) => element['_id'] != id).toList();
       setState(() {
         items = filtered;
       });
    } else{
       showErrorMessage(context, message:'Delation Failed');
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchTodos();
    if(response != null){
       setState(() {
         items = response;
       });
    } else{
      showErrorMessage(context, message:'Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }
}
