import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reseller_plusgrow/order_detail.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {

  String apiToken = '', name = '', errMessage = '';
  late OrdersListApiData ordersListApiData;
  bool isLoaded = false;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken")??'';
    });
    ordersListApiData = await getList();
    setState(() {
      isLoaded = true;
    });
  }

  Future<OrdersListApiData> getList() async {
    final response = await http.get(Uri.https(globals.baseURL,"/api/orders"),  headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $apiToken'});
    var resCode = response.statusCode;
    if(resCode == 200){
      OrdersListApiData ordersListApiData = ordersListApiDataFromJson(response.body);
      return ordersListApiData;
    }
    else{
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return OrdersListApiData(message: 'Oops! Something went wrong.', orders: Orders(currentPage: 0, data: [], firstPageUrl: '', from: 0, lastPage: 0, lastPageUrl: '', links: [], nextPageUrl: '', path: '', perPage: 0, prevPageUrl: '', to: 0, total: 0));
    }
  }

  goBack(){
    Navigator.pushNamed(context, 'login');
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
        title: const Text('Order History'),     
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
      errMessage.isNotEmpty ? Center(child: Text(errMessage),) : ordersListApiData.orders.data.isEmpty ? const Center(child: Text('No Data')) : 
      ListView.builder(
        itemCount: ordersListApiData.orders.data.length,
        itemBuilder: (context, index) => getOrderRow(index)
      ),
    );
  }

  Widget getOrderRow(int index) {
    return Column(
      children: <Widget>[
        SizedBox(
          child: GestureDetector(
            onTap: (){},
            child: Container(
              alignment: const Alignment(0, 0),
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(5.0, 5.0),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        SizedBox(
                          child: Text(
                            '# ${ordersListApiData.orders.data[index].name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Container(
                            margin: const EdgeInsets.only(top: 40, left: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.0,
                                    color: Color.fromRGBO(47, 93 , 255, 1)
                                  ),
                                ),
                                Text(
                                  ordersListApiData.orders.data[index].totalPrice,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22.0,
                                    color: Color.fromRGBO(47, 93 , 255, 1)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check, size: 16,color: Colors.green),
                            const Padding(padding: EdgeInsets.only(right: 4)),
                            Row(
                              children: [
                                const Text(
                                  'Order Date: ',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                  ),
                                ),
                                Text(
                                  DateFormat.yMMMd().format(ordersListApiData.orders.data[index].orderDate),
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        Row(
                          children: [
                            const Icon(Icons.check, size: 16,color: Colors.green),
                            const Padding(padding: EdgeInsets.only(right: 4)),
                            Row(
                              children: [
                                const Text(
                                  'Products Count: ',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                  ),
                                ),
                                Text(
                                  ordersListApiData.orders.data[index].lineItemsCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderDetail(ordersListApiData.orders.data[index].orderId)),
                              );
                            }, 
                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(47, 93, 255, 1))),
                            child: Container(
                              padding: const EdgeInsets.all(0.0),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('View Details'),
                                ],
                              ),
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


OrdersListApiData ordersListApiDataFromJson(String str) => OrdersListApiData.fromJson(json.decode(str));

String ordersListApiDataToJson(OrdersListApiData data) => json.encode(data.toJson());

class OrdersListApiData {
    final String message;
    final Orders orders;

    OrdersListApiData({
        required this.message,
        required this.orders,
    });

    factory OrdersListApiData.fromJson(Map<String, dynamic> json) => OrdersListApiData(
        message: json["message"],
        orders: Orders.fromJson(json["orders"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "orders": orders.toJson(),
    };
}

class Orders {
    final int currentPage;
    final List<Datum> data;
    final String firstPageUrl;
    final int from;
    final int lastPage;
    final String lastPageUrl;
    final List<Link> links;
    final dynamic nextPageUrl;
    final String path;
    final int perPage;
    final dynamic prevPageUrl;
    final int to;
    final int total;

    Orders({
        required this.currentPage,
        required this.data,
        required this.firstPageUrl,
        required this.from,
        required this.lastPage,
        required this.lastPageUrl,
        required this.links,
        this.nextPageUrl,
        required this.path,
        required this.perPage,
        this.prevPageUrl,
        required this.to,
        required this.total,
    });

    factory Orders.fromJson(Map<String, dynamic> json) => Orders(
        currentPage: json["current_page"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
    };
}

class Datum {
    final int id;
    final int customerId;
    final int orderId;
    final String name;
    final DateTime orderDate;
    final String totalPrice;
    final String? fulfillmentStatus;
    final int lineItemsCount;

    Datum({
        required this.id,
        required this.customerId,
        required this.orderId,
        required this.name,
        required this.orderDate,
        required this.totalPrice,
        this.fulfillmentStatus,
        required this.lineItemsCount,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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

class Link {
    final String? url;
    final String label;
    final bool? active;

    Link({
        this.url,
        required this.label,
        this.active,
    });

    factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
    );

    Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
    };
}
