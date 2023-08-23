import 'package:flutter/material.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuickOrder extends StatefulWidget {
  const QuickOrder({super.key});

  @override
  State<QuickOrder> createState() => _QuickOrderState();
}

class _QuickOrderState extends State<QuickOrder> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

OrderDetailApiData orderDetailApiDataFromJson(String str) => OrderDetailApiData.fromJson(json.decode(str));

String orderDetailApiDataToJson(OrderDetailApiData data) => json.encode(data.toJson());

class OrderDetailApiData {
    final String message;
    final List<ProductVariant> productVariants;

    OrderDetailApiData({
        required this.message,
        required this.productVariants,
    });

    factory OrderDetailApiData.fromJson(Map<String, dynamic> json) => OrderDetailApiData(
        message: json["message"],
        productVariants: List<ProductVariant>.from(json["product_variants"].map((x) => ProductVariant.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "product_variants": List<dynamic>.from(productVariants.map((x) => x.toJson())),
    };
}

class ProductVariant {
    final int id;
    final int productId;
    final int inventoryItemId;
    final int variantId;
    final String title;
    final String price;
    final String sku;
    final int inventoryQuantity;
    final int storeId;
    final String imageSrc;
    final String productTitle;
    final String vendor;
    final String productType;
    final String discountText;
    final Product product;

    ProductVariant({
        required this.id,
        required this.productId,
        required this.inventoryItemId,
        required this.variantId,
        required this.title,
        required this.price,
        required this.sku,
        required this.inventoryQuantity,
        required this.storeId,
        required this.imageSrc,
        required this.productTitle,
        required this.vendor,
        required this.productType,
        required this.discountText,
        required this.product,
    });

    factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: json["id"],
        productId: json["product_id"],
        inventoryItemId: json["inventory_item_id"],
        variantId: json["variant_id"],
        title: json["title"],
        price: json["price"],
        sku: json["sku"],
        inventoryQuantity: json["inventory_quantity"],
        storeId: json["store_id"],
        imageSrc: json["image_src"],
        productTitle: json["product_title"],
        vendor: json["vendor"],
        productType: json["product_type"],
        discountText: json["discount_text"],
        product: Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "inventory_item_id": inventoryItemId,
        "variant_id": variantId,
        "title": title,
        "price": price,
        "sku": sku,
        "inventory_quantity": inventoryQuantity,
        "store_id": storeId,
        "image_src": imageSrc,
        "product_title": productTitle,
        "vendor": vendor,
        "product_type": productType,
        "discount_text": discountText,
        "product": product.toJson(),
    };
}

class Product {
    final int id;
    final int productId;
    final String publishedScope;
    final int status;
    final int storeId;

    Product({
        required this.id,
        required this.productId,
        required this.publishedScope,
        required this.status,
        required this.storeId,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        publishedScope: json["published_scope"],
        status: json["status"],
        storeId: json["store_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "published_scope": publishedScope,
        "status": status,
        "store_id": storeId,
    };
}
