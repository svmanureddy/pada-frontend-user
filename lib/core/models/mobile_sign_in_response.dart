// To parse this JSON data, do
//
//     final mobileSignInResponse = mobileSignInResponseFromJson(jsonString);

import 'dart:convert';

MobileSignInResponse mobileSignInResponseFromJson(String str) => MobileSignInResponse.fromJson(json.decode(str));

String mobileSignInResponseToJson(MobileSignInResponse data) => json.encode(data.toJson());

class MobileSignInResponse {
  bool? success;
  String? message;
  Data? data;

  MobileSignInResponse({
    this.success,
    this.message,
    this.data,
  });

  factory MobileSignInResponse.fromJson(Map<String, dynamic> json) => MobileSignInResponse(
    success: json["success"] as bool?,
    message: json["message"]?.toString(),
    data: json["data"] == null ? null : Data.fromJson(json["data"] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? accessToken;
  String? refreshToken;
  User? user;

  Data({this.accessToken, this.refreshToken, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken']?.toString();
    refreshToken = json['refreshToken']?.toString();
    user = json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? sId;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? socialId;
  String? email;
  int? wallet;
  String? image;
  String? deviceToken;
  String? shortCode;
  int? userType;
  bool? active;
  bool? isVerified;
  String? registeredWith;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  User(
      {this.sId,
        this.firstName,
        this.lastName,
        this.phoneNumber,
        this.socialId,
        this.email,
        this.wallet,
        this.image,
        this.deviceToken,
        this.shortCode,
        this.userType,
        this.active,
        this.isVerified,
        this.registeredWith,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.id});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    phoneNumber = json['phoneNumber']?.toString();
    socialId = json['socialId']?.toString();
    email = json['email']?.toString();
    wallet = json['wallet'] is int ? json['wallet'] as int? : (json['wallet'] is num ? (json['wallet'] as num).toInt() : null);
    image = json['image']?.toString();
    deviceToken = json['deviceToken']?.toString();
    shortCode = json['shortCode']?.toString();
    userType = json['userType'] is int ? json['userType'] as int? : (json['userType'] is num ? (json['userType'] as num).toInt() : null);
    active = json['active'] as bool?;
    isVerified = json['isVerified'] as bool?;
    registeredWith = json['registeredWith']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    iV = json['__v'] is int ? json['__v'] as int? : (json['__v'] is num ? (json['__v'] as num).toInt() : null);
    id = json['id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['phoneNumber'] = phoneNumber;
    data['socialId'] = socialId;
    data['email'] = email;
    data['wallet'] = wallet;
    data['image'] = image;
    data['deviceToken'] = deviceToken;
    data['shortCode'] = shortCode;
    data['userType'] = userType;
    data['active'] = active;
    data['isVerified'] = isVerified;
    data['registeredWith'] = registeredWith;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}