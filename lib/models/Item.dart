class Item {
  int id;
  int listId;
  int done;
  String title;
  String description;
  DateTime dueDate;
  int repetitionDays;
  Item(
      {this.done,
      this.title,
      this.description,
      this.id,
      this.dueDate,
      this.repetitionDays});

  Map<String, dynamic> toMap() => {
        "id": id,
        "list_id": listId,
        "done": done,
        "title": title,
        "description": description,
        "due_date": dueDate,
        "repetition_days": repetitionDays,
      };
}
