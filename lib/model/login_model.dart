import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

class LoginModel {
  LoginModel({
    this.success,
    this.message,
    this.accessToken,
    this.tokenType,
    this.counter,
    this.counterGroupList,
  });

  final bool? success;
  final String? message;
  final String? accessToken;
  final String? tokenType;
  final Counter? counter;
  final List<CounterGroupList>? counterGroupList;

  factory LoginModel.fromJson(Map<String?, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"].toString(),
    accessToken: json["access_token"].toString(),
    tokenType: json["token_type"].toString(),
    counter: Counter.fromJson(json["counter"]),
    counterGroupList: List<CounterGroupList>.from(json["counter_group_list"].map((x) => CounterGroupList.fromJson(x))),
  );
}

class Counter {
  Counter({
    this.id,
    this.counterName,
    this.countermanName,
    this.username,
    this.counterGroupId,
    this.counterGroupName,
    this.mobile,
    this.lastSlNo,
    this.status,
  });

  final String? id;
  final String? counterName;
  final String? countermanName;
  final String? username;
  final String? counterGroupId;
  final String? counterGroupName;
  final String? mobile;
  final String? lastSlNo;
  final String? status;

  factory Counter.fromJson(Map<String?, dynamic> json) => Counter(
    id: json["id"].toString(),
    counterName: json["counter_name"].toString(),
    countermanName: json["counterman_name"].toString(),
    username: json["username"].toString(),
    counterGroupId: json["counter_group_id"].toString(),
    counterGroupName: json["counter_group_name"].toString(),
    mobile: json["mobile"].toString(),
    lastSlNo: json["last_sl_no"].toString(),
    status: json["status"].toString(),
  );
}

class CounterGroupList {
  CounterGroupList({
    this.id,
    this.toGroupId,
    this.toGroupName,
    this.regularFare,
    this.studentFare,
    this.toll,
  });

  final String? id;
  final String? toGroupId;
  final String? toGroupName;
  final String? regularFare;
  final String? studentFare;
  final String? toll;

  factory CounterGroupList.fromJson(Map<String?, dynamic> json) => CounterGroupList(
    id: json["id"].toString(),
    toGroupId: json["to_group_id"].toString(),
    toGroupName: json["to_group_name"].toString(),
    regularFare: json["regular_fare"].toString(),
    studentFare: json["student_fare"].toString(),
    toll: json["toll"].toString(),
  );
}