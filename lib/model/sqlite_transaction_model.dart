class SqliteTransactionModel{
  int? id;
  String? fromCounterId;
  String? toGroupId;
  String? totalFare;
  String? regularFare;
  String? studentFare;
  String? toll;
  String? slNo;
  String? date;
  SqliteTransactionModel(this.fromCounterId,this.toGroupId,this.totalFare,this.regularFare,this.studentFare,this.toll,this.slNo,this.date);

  //Convert a note object to mop object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (id != null) {map['id'] = id;}
    map['fromCounterId'] = fromCounterId;
    map['toGroupId'] = toGroupId;
    map['totalFare'] = totalFare;
    map['regularFare'] = regularFare;
    map['studentFare'] = studentFare;
    map['toll'] = toll;
    map['slNo'] = slNo;
    map['date'] = date;
    return map;
  }

  //Extract a note object from a map object
  SqliteTransactionModel.fromMapObject(Map<String, dynamic> map) {
    id = map['id'];
    fromCounterId = map['fromCounterId'];
    toGroupId = map['toGroupId'];
    totalFare = map['totalFare'];
    regularFare = map['regularFare'];
    studentFare = map['studentFare'];
    toll = map['toll'];
    slNo = map['slNo'];
    date = map['date'];
  }
}