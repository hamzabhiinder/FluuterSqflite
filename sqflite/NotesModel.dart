class NotesModel {
  final int? id;
  final String title;
  final String description;
  final int age;
  final String email;

  NotesModel(
      {this.id,
      required this.title,
      required this.description,
      required this.age,
      required this.email});

  NotesModel.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        title = res["title"],
        description = res["description"],
        age = res["age"],
        email = res["email"];

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "age": age,
      "email": email,
    };
  }
}
