import 'package:flutter/material.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reseller_plusgrow/ticket/detail.dart';

class TicketsHistory extends StatefulWidget {
  const TicketsHistory({super.key});

  @override
  State<TicketsHistory> createState() => _TicketsHistoryState();
}

class _TicketsHistoryState extends State<TicketsHistory> {
  String apiToken = '', errMessage = '';
  late HistoryApiData historyApiData;
  bool isLoaded = false;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    historyApiData = await getList();
    setState(() {
      isLoaded = true;
    });
  }

  Future<HistoryApiData> getList() async {
    final response =
      await http.post(Uri.https(globals.baseURL, "/api/warranty-history"), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $apiToken'
      },
      body: jsonEncode({}));
    var resCode = response.statusCode;
    if (resCode == 200) {
      HistoryApiData historyApiData =
          historyApiDataFromJson(response.body);
      return historyApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return HistoryApiData(
          message: 'Oops! Something went wrong.',
          status: false,
          tickets: []
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
      appBar: const globals.AppBarItems('Warranty History'),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : historyApiData.tickets.isEmpty
                  ? const Center(child: Text('No Data'))
                  : ListView.builder(
                      itemCount: historyApiData.tickets.length,
                      itemBuilder: (context, index) => getTicketsRow(index)),
    );
  }

  Widget getTicketsRow(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){ 
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Detail(historyApiData.tickets[index].ticketNo)),
          );
         },
        child: Card(
          elevation: 0,
          color: Colors.teal.shade300,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                '# ${historyApiData.tickets[index].ticketNo}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              subtitle: Text(historyApiData.tickets[index].createdAt,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              trailing: Text(historyApiData.tickets[index].status == 0 ? 'Open' : 'Closed',
                style: TextStyle(
                    color: historyApiData.tickets[index].status == 0 ? Colors.indigo : Colors.black54,
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

HistoryApiData historyApiDataFromJson(String str) => HistoryApiData.fromJson(json.decode(str));

String historyApiDataToJson(HistoryApiData data) => json.encode(data.toJson());

class HistoryApiData {
    bool status;
    String message;
    List<Ticket> tickets;

    HistoryApiData({
        required this.status,
        required this.message,
        required this.tickets,
    });

    factory HistoryApiData.fromJson(Map<String, dynamic> json) => HistoryApiData(
        status: json["status"],
        message: json["message"],
        tickets: List<Ticket>.from(json["tickets"].map((x) => Ticket.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "tickets": List<dynamic>.from(tickets.map((x) => x.toJson())),
    };
}

class Ticket {
    int id;
    String ticketNo;
    int customerId;
    String productName;
    String productSku;
    String invoiceNo;
    DateTime invoiceDate;
    String remark;
    int isImported;
    int status;
    String createdAt;
    int filesCount;
    int motoCommentsCount;

    Ticket({
        required this.id,
        required this.ticketNo,
        required this.customerId,
        required this.productName,
        required this.productSku,
        required this.invoiceNo,
        required this.invoiceDate,
        required this.remark,
        required this.isImported,
        required this.status,
        required this.createdAt,
        required this.filesCount,
        required this.motoCommentsCount,
    });

    factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json["id"],
        ticketNo: json["ticket_no"],
        customerId: json["customer_id"],
        productName: json["product_name"],
        productSku: json["product_sku"],
        invoiceNo: json["invoice_no"],
        invoiceDate: DateTime.parse(json["invoice_date"]),
        remark: json["remark"],
        isImported: json["is_imported"],
        status: json["status"],
        createdAt: json["created_at"],
        filesCount: json["files_count"],
        motoCommentsCount: json["moto_comments_count"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "ticket_no": ticketNo,
        "customer_id": customerId,
        "product_name": productName,
        "product_sku": productSku,
        "invoice_no": invoiceNo,
        "invoice_date": "${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}",
        "remark": remark,
        "is_imported": isImported,
        "status": status,
        "created_at": createdAt,
        "files_count": filesCount,
        "moto_comments_count": motoCommentsCount,
    };
}
