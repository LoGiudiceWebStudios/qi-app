


import 'dart:convert';

class VerificationModel {
  bool? status;
  String? message;
  int? code;
  String? tokenType;
  String? token;
  UserData? data;

  VerificationModel({
    this.status,
    this.message,
    this.code,
    this.tokenType,
    this.token,
    this.data,
  });

  VerificationModel copyWith({
    bool? status,
    String? message,
    int? code,
    String? tokenType,
    String? token,
    UserData? data,
  }) =>
      VerificationModel(
        status: status ?? this.status,
        message: message ?? this.message,
        code: code ?? this.code,
        tokenType: tokenType ?? this.tokenType,
        token: token ?? this.token,
        data: data ?? this.data,
      );

  factory VerificationModel.fromRawJson(String str) =>
      VerificationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerificationModel.fromJson(Map<String, dynamic> json) => VerificationModel(
    status: json["status"],
    message: json["message"],
    code: json["code"],
    tokenType: json["token_type"],
    token: json["token"],
    data: json["data"] != null ? UserData.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "code": code,
    "token_type": tokenType,
    "token": token,
    "data": data?.toJson(),
  };
}

class UserData {
  int? id;
  String? name;
  String? email;

  UserData({
    this.id,
    this.name,
    this.email,
  });

  UserData copyWith({
    int? id,
    String? name,
    String? email,
  }) =>
      UserData(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
      );

  factory UserData.fromRawJson(String str) => UserData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}
