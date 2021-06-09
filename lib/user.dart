import 'dart:convert';

// User userFromJson(String str) => User.fromJson(json.decode(str));
//
// String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.status,
    this.message,
    this.data,
  });

  bool status;
  String message;
  Data data;

  factory User.fromJson(Map<String, dynamic> json) => User(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.accountNumber,
    this.accountName,
    this.bankId,
  });

  String accountNumber;
  String accountName;
  int bankId;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    bankId: json["bank_id"],
  );

  Map<String, dynamic> toJson() => {
    "account_number": accountNumber,
    "account_name": accountName,
    "bank_id": bankId,
  };
}
