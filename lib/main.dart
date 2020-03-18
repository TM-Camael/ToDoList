import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tp_android/models/todo.dart';
import 'package:tp_android/database.dart';
import 'package:sqflite/sqflite.dart';



void main()=> runApp(MaterialApp(
	home:MyApp(),
	debugShowCheckedModeBanner: false,
));

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
	DatabaseHelper db = DatabaseHelper();
	List<ToDo> _todolist = [];
	final _tcontroller = TextEditingController();

/* Contruction de la page principale de l'application */
	@override
	Widget build(BuildContext context) {
		updateListView();
		return new Scaffold(
			appBar: new AppBar(
				title: new Text('A Not so Fancy Flutter To Do List'),
				actions: <Widget>[
					PopupMenuButton<String>( /* Sert à afficher le menu d'options */
						onSelected: (String choice){
							choiceAction(choice, context);
						},
						itemBuilder: (BuildContext context ){
							return Constants.Options.map((String choice){
								return PopupMenuItem<String>(
									value : choice,
									child : Text(choice),
								);
							}).toList();
						},
					)
				],
			),
			body:
			Column(
				crossAxisAlignment:CrossAxisAlignment.start,

				children: <Widget>[
					new Row(
						children: <Widget>[
							new Expanded(
								child: new TextField(
									controller: _tcontroller,
									decoration: InputDecoration(
										hintText: 'Ajouter une tâche',
									),

								),
							),
							RaisedButton(
								child: new Text('Ajouter'),
								onPressed: (){
									if(_tcontroller.text.isNotEmpty) {
										save(ToDo(null, _tcontroller.text));
										_tcontroller.clear();
										updateListView();
									}
								},
							)
						]

					),

					new Expanded(
						child : Container(
							child: new ListView.builder(
								itemCount: _todolist.length,
								itemBuilder: (context, index) {
									return PopupMenuButton<String>( /* Sert à afficher le menu contextuel */
										child: ListTile(
											title: Text(
												'${_todolist[index].texte}',
											),
											trailing: new IconButton(
												icon: new Icon(Icons.delete),
												onPressed: (){
													delete(_todolist[index]);
													updateListView();
												},
											),
										),
										onSelected: (String choice){
											contextMenuChoice(_todolist[index].texte, choice);
										},
										itemBuilder: (BuildContext context ) {
											return Constants.ContextMenu.map((String choice) {
												return PopupMenuItem<String>(
													value: choice,
													child: Text(choice),
												);
											}).toList();
										});
								},
							),
						)),
				],
			),


		);
	}
	/* Permet de traiter les éléments du menu d'options */
	void choiceAction(String choice, BuildContext context){
		if(choice == Constants.DeleteAll){
			showDialog(
				context: context,
				builder: (_) => AlertDialog(
					title: Text("Supprimer tout"),
					content: Text("Voulez vous vraiment supprimer ?"),
					actions: <Widget>[
						FlatButton(
							child: Text("Non"),
							onPressed: ()=>Navigator.pop(context),
						),
						FlatButton(
							child: Text("Oui"),
							onPressed: (){
								deleteAll();
								updateListView();
								Navigator.pop(context);
							},
						)
					],
				)

			);
		}
	}
	/* Permet de traiter les options du menu contextuel */
	void contextMenuChoice(String todotext, String choice) async {
		if(choice == Constants.Google){
			String query = Uri.encodeComponent(todotext);
			String googleUrl = "https://www.google.com/search?query=$query";
			if(await canLaunch(googleUrl)){
				await launch(googleUrl);
			}

		}
		if(choice == Constants.Maps) {
			String query = Uri.encodeComponent(todotext);
			String googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";
			if (await canLaunch(googleUrl)) {
				await launch(googleUrl);
			}
		}
	}
	/* Permet d'actualiser la todolist grâce à la bdd sqlite*/
	void updateListView() {
		final Future<Database> dbFuture = db.initializeDatabase();
		dbFuture.then((database) {
			Future<List<ToDo>> todoListFuture = db.todolist();
			todoListFuture.then((todoList) {
				setState(() {
					this._todolist = todoList;
				});
			});
		});
	}
	/* Permet de sauvegarder un élément dans la bdd*/
	void save(ToDo todo) async {
		await db.insertTodo(todo);
	}
	/* Permet de supprimer un élément dans la bdd*/
	void delete(ToDo todo) async{
		await db.deleteTodo(todo.id);
	}
	/* Permet de supprimer tous les éléments de la todolist dans la bdd */
	void deleteAll() async {
		await db.deleteAllTodo();
	}
}
