class Proyect {
  String name;
  String description;
  String backgroundImage;
  String membersGroup;
  int id;
  int orderIndex;
  int status;

  Proyect(
      {this.name,
      this.status,
      this.backgroundImage,
      this.membersGroup,
      this.description,
      this.id,
      this.orderIndex});

  Map<String, dynamic> toMap() {
    print('mapping $id');
    return {
      "id": id,
      "name": name,
      "description": description,
      "order_index": orderIndex,
      "background_image": backgroundImage,
      "status": status,
      "members_group": membersGroup
    };
  }
}
