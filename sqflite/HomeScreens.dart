import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:myapp/sqflite/DBhelper.dart';
import 'package:myapp/sqflite/NotesModel.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  DBHelper? _dbHelper;
  late Future<List<NotesModel>> notesList;

  loadData() async {
    notesList = _dbHelper!.getNotesList();
  }

  @override
  void initState() {
    _dbHelper = DBHelper();
    super.initState();
    loadData();
  }

  TextEditingController title = TextEditingController();
  TextEditingController descr = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQFLITE"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dbHelper!
              .insertTable(
                NotesModel(
                    title: "AmeerHamza",
                    description: "Some Discription are",
                    age: 12,
                    email: "Hamza@gamil.com"),
              )
              .then((value) => {
                    print("Successsssssss"),
                    setState(() {
                      notesList = _dbHelper!.getNotesList();
                    }),
                  })
              .onError((error, stackTrace) => {print(error.toString())});
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: notesList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: ValueKey<int>(snapshot.data![index].id!),
                      background: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete),
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _dbHelper!.deleteTable(snapshot.data![index].id!);
                          notesList = _dbHelper!.getNotesList();
                          snapshot.data!.remove(snapshot.data![index]);
                        });
                      },
                      child: Card(
                        child: ListTile(
                          onTap: () {
                            title.text = snapshot.data![index].title;
                            descr.text = snapshot.data![index].description;
                            age.text = snapshot.data![index].age.toString();
                            email.text = snapshot.data![index].email;

                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: 350,
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    children: [
                                      TextField(
                                          controller: title,
                                          decoration: InputDecoration(
                                              hintText: "title")),
                                      TextField(
                                          controller: descr,
                                          decoration: InputDecoration(
                                              hintText: "description")),
                                      TextField(
                                          controller: age,
                                          decoration:
                                              InputDecoration(hintText: "age")),
                                      TextField(
                                          controller: email,
                                          decoration: InputDecoration(
                                              hintText: "email")),
                                      ElevatedButton(
                                          onPressed: () {
                                            _dbHelper!.UpdateTable(NotesModel(
                                                id: snapshot.data![index].id!,
                                                title: title.text.toString(),
                                                description:
                                                    descr.text.toString(),
                                                age: int.parse(age.text),
                                                email: email.text.toString()));

                                            setState(() {
                                              notesList =
                                                  _dbHelper!.getNotesList();
                                            });

                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Update"))
                                    ],
                                  ),
                                );
                              },
                            );
                            BottomSheet(
                              onClosing: () {},
                              builder: (context) {
                                return Container();
                              },
                            );
                          },
                          title: Text(snapshot.data![index].title.toString()),
                          contentPadding: EdgeInsets.all(12),
                          subtitle: Text(
                              snapshot.data![index].description.toString()),
                          trailing: Text(snapshot.data![index].age.toString()),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
