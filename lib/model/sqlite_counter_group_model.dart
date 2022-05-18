class SqliteCounterGroupModel{
  int? id;
  String? toGroupId;
  String? toGroupName;
  String? regularFare;
  String? studentFare;
  String? toll;

  SqliteCounterGroupModel(this.toGroupId,this.toGroupName,this.regularFare, this.studentFare, this.toll);

  //Convert a note object to mop object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {map['id'] = id;}
    map['toGroupId'] = toGroupId;
    map['toGroupName'] = toGroupName;
    map['regularFare'] = regularFare;
    map['studentFare'] = studentFare;
    map['toll'] = toll;
    return map;
  }

  //Extract a note object from a map object
  SqliteCounterGroupModel.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    toGroupId = map['toGroupId'];
    toGroupName = map['toGroupName'];
    regularFare = map['regularFare'];
    studentFare = map['studentFare'];
    toll = map['toll'];
  }
}