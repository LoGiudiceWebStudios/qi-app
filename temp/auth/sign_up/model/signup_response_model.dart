import 'dart:convert';

import '../../../category_wise_event/model/gender_count_response_model.dart';

// class SignUpResponseModel {
//     bool? status;
//     String? message;
//     int? code;
//     String? tokenType;
//     String? token;
//     Data? data;
//
//     SignUpResponseModel({
//         this.status,
//         this.message,
//         this.code,
//         this.tokenType,
//         this.token,
//         this.data,
//     });
//
//     SignUpResponseModel copyWith({
//         bool? status,
//         String? message,
//         int? code,
//         String? tokenType,
//         String? token,
//         Data? data,
//     }) =>
//         SignUpResponseModel(
//             status: status ?? this.status,
//             message: message ?? this.message,
//             code: code ?? this.code,
//             tokenType: tokenType ?? this.tokenType,
//             token: token ?? this.token,
//             data: data ?? this.data,
//         );
//
//     factory SignUpResponseModel.fromRawJson(String str) => SignUpResponseModel.fromJson(json.decode(str));
//
//     String toRawJson() => json.encode(toJson());
//
//     factory SignUpResponseModel.fromJson(Map<String, dynamic> json) => SignUpResponseModel(
//         status: json["status"],
//         message: json["message"],
//         code: json["code"],
//         tokenType: json["token_type"],
//         token: json["token"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     );
//
//     Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "code": code,
//         "token_type": tokenType,
//         "token": token,
//         "data": data?.toJson(),
//     };
// }
//
// class Data {
//     int? id;
//     String? name;
//     String? email;
//
//     Data({
//         this.id,
//         this.name,
//         this.email,
//     });
//
//     Data copyWith({
//         int? id,
//         String? name,
//         String? email,
//     }) =>
//         Data(
//             id: id ?? this.id,
//             name: name ?? this.name,
//             email: email ?? this.email,
//         );
//
//     factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));
//
//     String toRawJson() => json.encode(toJson());
//
//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         id: json["id"],
//         name: json["name"],
//         email: json["email"],
//     );
//
//     Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "email": email,
//     };
// }


class SignUpResponseModel {
    bool? status;
    String? message;
    int? code;
    String? tokenType;
    String? token;
    List<Data>? data; // Change `Data?` to `List<Data>?` to handle lists.

    SignUpResponseModel({
        this.status,
        this.message,
        this.code,
        this.tokenType,
        this.token,
        this.data,
    });

    SignUpResponseModel copyWith({
        bool? status,
        String? message,
        int? code,
        String? tokenType,
        String? token,
        List<Data>? data,
    }) =>
        SignUpResponseModel(
            status: status ?? this.status,
            message: message ?? this.message,
            code: code ?? this.code,
            tokenType: tokenType ?? this.tokenType,
            token: token ?? this.token,
            data: data ?? this.data,
        );

    factory SignUpResponseModel.fromRawJson(String str) =>
        SignUpResponseModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SignUpResponseModel.fromJson(Map<String, dynamic> json) =>
        SignUpResponseModel(
            status: json["status"],
            message: json["message"],
            code: json["code"],
            tokenType: json["token_type"],
            token: json["token"],
            data: json["data"] == null
                ? []
                : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "code": code,
        "token_type": tokenType,
        "token": token,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}
