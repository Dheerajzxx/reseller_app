import 'package:flutter/material.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderDetail extends StatefulWidget {
  final int orderId;
  const OrderDetail(this.orderId, {super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {

  String apiToken = '', errMessage = '';
  late OrderDetailApiData orderDetailApiData;
  bool isLoaded = false;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    orderDetailApiData = await getDetails();
    setState(() {
      isLoaded = true;
    });
  }

  Future<OrderDetailApiData> getDetails() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/order-details"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    }, body: jsonEncode({
      "order_id":widget.orderId
    }));
    var resCode = response.statusCode;
    if (resCode == 200) {
      OrderDetailApiData orderDetailApiData = orderDetailApiDataFromJson(response.body);
      return orderDetailApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return OrderDetailApiData(
          message: 'Oops! Something went wrong.',
          order: Order(
              id:0,
              customerId:0,
              orderId:0,
              name:'',
              totalPrice:'',
              lineItems:[],
              notes:[]
          )
      );
    }
  }

  errorToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        webPosition: "center",
        webBgColor: "linear-gradient(to top, red, yellow)",
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(14, 29, 48, 1),   
        title: const Text("Order Details"),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_outlined ),
          )
        ],
      ),
      body:
      !isLoaded ? const Center(child: CircularProgressIndicator(),):
      errMessage.isNotEmpty ? Center(child: Text(errMessage),) : orderDetailApiData.order.lineItems.isEmpty ? const Center(child: Text('No Data')) : 
      ListView.builder(
        itemCount: orderDetailApiData.order.lineItems.length,
        itemBuilder: (context, index) => getProductRow(index)
      ),
    );
  }

  Widget getProductRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        color: Colors.teal.shade300,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              orderDetailApiData.order.lineItems[index].name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            subtitle: Text(
                '${orderDetailApiData.order.lineItems[index].variant.title} - ${orderDetailApiData.order.lineItems[index].sku}${orderDetailApiData.order.lineItems[index].sku != ''? " - " : ''}${orderDetailApiData.order.lineItems[index].grams}',
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            trailing: Text(
              "₹ ${orderDetailApiData.order.lineItems[index].price} x ${orderDetailApiData.order.lineItems[index].quantity}",
              style: const TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

OrderDetailApiData orderDetailApiDataFromJson(String str) => OrderDetailApiData.fromJson(json.decode(str));

String orderDetailApiDataToJson(OrderDetailApiData data) => json.encode(data.toJson());

class OrderDetailApiData {
    final String message;
    final Order order;

    OrderDetailApiData({
        required this.message,
        required this.order,
    });

    factory OrderDetailApiData.fromJson(Map<String, dynamic> json) => OrderDetailApiData(
        message: json["message"],
        order: Order.fromJson(json["order"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "order": order.toJson(),
    };
}

class Order {
    final int id;
    final int customerId;
    final int orderId;
    final String name;
    final String totalPrice;
    final List<LineItem> lineItems;
    final List<Note> notes;

    Order({
        required this.id,
        required this.customerId,
        required this.orderId,
        required this.name,
        required this.totalPrice,
        required this.lineItems,
        required this.notes,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        customerId: json["customer_id"],
        orderId: json["order_id"],
        name: json["name"],
        totalPrice: json["total_price"],
        lineItems: List<LineItem>.from(json["line_items"].map((x) => LineItem.fromJson(x))),
        notes: List<Note>.from(json["notes"].map((x) => Note.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "order_id": orderId,
        "name": name,
        "total_price": totalPrice,
        "line_items": List<dynamic>.from(lineItems.map((x) => x.toJson())),
        "notes": List<dynamic>.from(notes.map((x) => x.toJson())),
    };
}

class LineItem {
    final int id;
    final int lineItemId;
    final String name;
    final String sku;
    final String price;
    final int quantity;
    final String grams;
    final int productExists;
    final int productId;
    final int variantId;
    final Variant variant;

    LineItem({
        required this.id,
        required this.lineItemId,
        required this.name,
        required this.sku,
        required this.price,
        required this.quantity,
        required this.grams,
        required this.productExists,
        required this.productId,
        required this.variantId,
        required this.variant,
    });

    factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        id: json["id"],
        lineItemId: json["line_item_id"],
        name: json["name"],
        sku: json["sku"] ?? '',
        price: json["price"],
        quantity: json["quantity"],
        grams: json["grams"],
        productExists: json["product_exists"],
        productId: json["product_id"],
        variantId: json["variant_id"],
        variant: Variant.fromJson(json["variant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "line_item_id": lineItemId,
        "name": name,
        "sku": sku,
        "price": price,
        "quantity": quantity,
        "grams": grams,
        "product_exists": productExists,
        "product_id": productId,
        "variant_id": variantId,
        "variant": variant.toJson(),
    };
}

class Variant {
    final int id;
    final int inventoryItemId;
    final String title;
    final int inventoryQuantity;
    final int storeId;
    final Product product;

    Variant({
        required this.id,
        required this.inventoryItemId,
        required this.title,
        required this.inventoryQuantity,
        required this.storeId,
        required this.product,
    });

    factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        id: json["id"],
        inventoryItemId: json["inventory_item_id"],
        title: json["title"],
        inventoryQuantity: json["inventory_quantity"],
        storeId: json["store_id"],
        product: Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "inventory_item_id": inventoryItemId,
        "title": title,
        "inventory_quantity": inventoryQuantity,
        "store_id": storeId,
        "product": product.toJson(),
    };
}

class Product {
    final int id;
    final int productId;
    final String title;
    final String vendor;
    final String productType;
    final int status;
    final int storeId;

    Product({
        required this.id,
        required this.productId,
        required this.title,
        required this.vendor,
        required this.productType,
        required this.status,
        required this.storeId,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        title: json["title"],
        vendor: json["vendor"],
        productType: json["product_type"],
        status: json["status"],
        storeId: json["store_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "title": title,
        "vendor": vendor,
        "product_type": productType,
        "status": status,
        "store_id": storeId,
    };
}

class Note {
    final int id;
    final String note;
    final int createdBy;
    final int type;
    final String createdAt;

    Note({
        required this.id,
        required this.note,
        required this.createdBy,
        required this.type,
        required this.createdAt,
    });

    factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        note: json["note"],
        createdBy: json["created_by"],
        type: json["type"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "note": note,
        "created_by": createdBy,
        "type": type,
        "created_at": createdAt,
    };
}