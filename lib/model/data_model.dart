// To parse this JSON data, do
//
//     final dataModel = dataModelFromJson(jsonString);

import 'dart:convert';

DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));

String dataModelToJson(DataModel data) => json.encode(data.toJson());

class DataModel {
  String lat;
  String longt;
  int userId;

  DataModel({
    required this.lat,
    required this.longt,
    required this.userId,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    lat: json["lat"],
    longt: json["longt"],
    userId: json["userID"],
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "longt": longt,
    "userID": userId,
  };
}
