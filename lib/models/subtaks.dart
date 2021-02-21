class Subtask {
  int id;
  int done;
  String title;
  int taskId;
  Subtask({this.done, this.title, this.id, this.taskId});

  Map<String, dynamic> toMap() =>
      {"id": id, "done": done, "title": title, "task_id": taskId};
}
