class Protocol {
  String name;
  String description;
  int id;
  int orderIndex;

  Protocol({this.name, this.description, this.id, this.orderIndex});

  Map<String, dynamic> toMap() {
    print('mapping $id');
    return {
      "id": id,
      "name": name,
      "description": description,
      "orderIndex": orderIndex
    };
  }
}
