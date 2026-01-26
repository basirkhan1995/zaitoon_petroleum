// To parse this JSON data, do
//
//     final cardxModel = cardxModelFromMap(jsonString);

import 'dart:convert';

List<CardxModel> cardxModelFromMap(String str) => List<CardxModel>.from(json.decode(str).map((x) => CardxModel.fromMap(x)));

String cardxModelToMap(List<CardxModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class CardxModel {
  final int? no;
  final int? orderId;
  final int? productId;
  final String? productName;
  final int? storageId;
  final String? storageName;
  final String? entryType;
  final DateTime? entryDate;
  final String? quantity;
  final String? price;
  final String? runningQuantity;

  CardxModel({
    this.no,
    this.orderId,
    this.productId,
    this.productName,
    this.storageId,
    this.storageName,
    this.entryType,
    this.entryDate,
    this.quantity,
    this.price,
    this.runningQuantity,
  });

  CardxModel copyWith({
    int? no,
    int? orderId,
    int? productId,
    String? productName,
    int? storageId,
    String? storageName,
    String? entryType,
    DateTime? entryDate,
    String? quantity,
    String? price,
    String? runningQuantity,
  }) =>
      CardxModel(
        no: no ?? this.no,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        storageId: storageId ?? this.storageId,
        storageName: storageName ?? this.storageName,
        entryType: entryType ?? this.entryType,
        entryDate: entryDate ?? this.entryDate,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        runningQuantity: runningQuantity ?? this.runningQuantity,
      );

  factory CardxModel.fromMap(Map<String, dynamic> json) => CardxModel(
    no: json["No"],
    orderId: json["orderID"],
    productId: json["productID"],
    productName: json["productName"],
    storageId: json["storageID"],
    storageName: json["storageName"],
    entryType: json["entryType"],
    entryDate: json["entryDate"] == null ? null : DateTime.parse(json["entryDate"]),
    quantity: json["quantity"],
    price: json["price"],
    runningQuantity: json["runningQuantity"],
  );

  Map<String, dynamic> toMap() => {
    "No": no,
    "orderID": orderId,
    "productID": productId,
    "productName": productName,
    "storageID": storageId,
    "storageName": storageName,
    "entryType": entryType,
    "entryDate": "${entryDate!.year.toString().padLeft(4, '0')}-${entryDate!.month.toString().padLeft(2, '0')}-${entryDate!.day.toString().padLeft(2, '0')}",
    "quantity": quantity,
    "price": price,
    "runningQuantity": runningQuantity,
  };
}
