class Room {
  String roomName;
  int total, complete;

  Room({this.roomName, this.complete, this.total});

  Map<String, dynamic> toJson() {
    return ({
      'name': roomName,
      'total': total,
      'complete': complete,
    });
  }
}
