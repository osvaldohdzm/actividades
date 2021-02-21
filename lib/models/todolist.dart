class Todolist {
  String name;
  String color;
  int id;
  int orderIndex;
  String tasksSort;
  Todolist({this.name, this.color, this.id, this.orderIndex, this.tasksSort});

  Map<String, dynamic> toMap() {
    print('mapping $id');
    return {
      "id": id,
      "name": name,
      "color": color,
      "order_index": orderIndex,
      "tasks_sort": tasksSort
    };
  }
}
