import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reseller_plusgrow/order_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastFive extends StatefulWidget {
  const LastFive({super.key});

  @override
  State<LastFive> createState() => _LastFiveState();
}

class _LastFiveState extends State<LastFive> {
  String apiToken = '', errMessage = '';
  String? search = '';
  TextEditingController editingController = TextEditingController();
  late OrdersListApiData ordersListApiData;
  bool isLoaded = true;
  Timer? _debounce;

  List newlist = List.filled(0, null, growable: true);

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
  }

  void filterSearchResults(String query) {
    if (query.length > 2) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          isLoaded = false;
          search = query;
        });
        getOrders();
      });
    }
  }

  Future<OrdersListApiData> getOrders() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/last-5-purchases"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiToken'
            },
            body: jsonEncode({"search": search}));
    var resCode = response.statusCode;
    setState(() {
      isLoaded = true;
    });
    if (resCode == 200) {
      OrdersListApiData ordersListApiData =
          ordersListApiDataFromJson(response.body);
      setState(() {
        newlist = ordersListApiData.orders;
      });
      return ordersListApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return OrdersListApiData(
          message: 'Oops! Something went wrong.', orders: []);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
        title: const Text('Last 5 Purchases'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_outlined),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: const InputDecoration(
                    labelText: "Search By SKU",
                    hintText: "Search By SKU",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: !isLoaded
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errMessage.isNotEmpty
                      ? Center(
                          child: Text(errMessage),
                        )
                      : newlist.isEmpty
                          ? const Center(child: Text('No Data Found!!'))
                          : ListView.builder(
                              itemCount: newlist.length,
                              itemBuilder: (context, index) =>
                                  getOrderRow(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getOrderRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){ 
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderDetail(newlist[index].orderId)),
          );
         },
        child: Card(
          elevation: 0,
          color: Colors.teal.shade300,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                '# ${newlist[index].name}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              subtitle: Text(
                  DateFormat.yMMMd()
                      .format(newlist[index].orderDate),
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              trailing: Text(
                "₹ ${newlist[index].totalPrice}",
                style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



OrdersListApiData ordersListApiDataFromJson(String str) => OrdersListApiData.fromJson(json.decode(str));

String ordersListApiDataToJson(OrdersListApiData data) => json.encode(data.toJson());

class OrdersListApiData {
    String message;
    List<Order> orders;
    // Customer customer;

    OrdersListApiData({
        required this.message,
        required this.orders,
        // required this.customer,
    });

    factory OrdersListApiData.fromJson(Map<String, dynamic> json) => OrdersListApiData(
        message: json["message"],
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
        // customer: Customer.fromJson(json["customer"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
        // "customer": customer.toJson(),
    };
}

class Order {
    int id;
    int customerId;
    int orderId;
    String name;
    DateTime orderDate;
    String totalPrice;
    String? fulfillmentStatus;
    int lineItemsCount;

    Order({
        required this.id,
        required this.customerId,
        required this.orderId,
        required this.name,
        required this.orderDate,
        required this.totalPrice,
        this.fulfillmentStatus,
        required this.lineItemsCount,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        customerId: json["customer_id"],
        orderId: json["order_id"],
        name: json["name"],
        orderDate: DateTime.parse(json["order_date"]),
        totalPrice: json["total_price"],
        fulfillmentStatus: json["fulfillment_status"],
        lineItemsCount: json["line_items_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "order_id": orderId,
        "name": name,
        "order_date": orderDate.toIso8601String(),
        "total_price": totalPrice,
        "fulfillment_status": fulfillmentStatus,
        "line_items_count": lineItemsCount,
    };
}

/*
class Customer {
    int id;
    int customerId;
    String email;
    String firstName;
    String lastName;
    dynamic phone;
    String ordersCount;
    String totalSpent;
    int status;
    DateTime createdAt;
    DateTime updatedAt;
    String tags;
    dynamic dropboxLink;
    dynamic trackingLink;
    int passCode;
    String passCodeValidTill;
    String apiToken;
    int storeId;

    Customer({
        required this.id,
        required this.customerId,
        required this.email,
        required this.firstName,
        required this.lastName,
        required this.phone,
        required this.ordersCount,
        required this.totalSpent,
        required this.status,
        required this.createdAt,
        required this.updatedAt,
        required this.tags,
        required this.dropboxLink,
        required this.trackingLink,
        required this.passCode,
        required this.passCodeValidTill,
        required this.apiToken,
        required this.storeId,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        customerId: json["customer_id"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        ordersCount: json["orders_count"],
        totalSpent: json["total_spent"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        tags: json["tags"],
        dropboxLink: json["dropbox_link"],
        trackingLink: json["tracking_link"],
        passCode: json["pass_code"],
        passCodeValidTill: json["pass_code_valid_till"],
        apiToken: json["api_token"],
        storeId: json["store_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "orders_count": ordersCount,
        "total_spent": totalSpent,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "tags": tags,
        "dropbox_link": dropboxLink,
        "tracking_link": trackingLink,
        "pass_code": passCode,
        "pass_code_valid_till": passCodeValidTill,
        "api_token": apiToken,
        "store_id": storeId,
    };
}

*/
