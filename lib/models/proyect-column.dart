class ProyectColumn {
  String title;
  String description;
  int id;
  int orderIndex;

  ProyectColumn({this.title, this.description, this.id, this.orderIndex});

  Map<String, dynamic> toMap() {
    print('mapping $id');
    return {
      "id": id,
      "title": title,
      "description": description,
      "order_index": orderIndex,
    };
  }
}
