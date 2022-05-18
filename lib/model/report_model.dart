import 'dart:convert';

ReportModel reportModelFromJson(String str) => ReportModel.fromJson(json.decode(str));

class ReportModel {
  ReportModel({
    this.success,
    this.data,
  });

  final bool? success;
  final Data? data;

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );
}

class Data {
  Data({
    this.id,
    this.date,
    this.counterName,
    this.totalFare,
    this.totalTicket,
  });

   String? id;
   DateTime? date;
   String? counterName;
   String? totalFare;
   String? totalTicket;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"].toString(),
    date: DateTime.parse(json["date"]),
    counterName: json["counter_name"].toString(),
    totalFare: json["total_fare"].toString(),
    totalTicket: json["total_ticket"].toString(),
  );
}
