import 'package:flutter/material.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail extends StatefulWidget {
  final String ticketNo;
  const Detail(this.ticketNo, {super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  String apiToken = '', errMessage = '';
  late DetailApiData detailApiData;
  bool isLoaded = false;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    detailApiData = await getDetails();
    setState(() {
      isLoaded = true;
    });
  }

  Future<DetailApiData> getDetails() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/warranty-detail"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    }, body: jsonEncode({
      "ticket_no":widget.ticketNo
    }));
    var resCode = response.statusCode;
    if (resCode == 200) {
      DetailApiData detailApiData = detailApiDataFromJson(response.body);
      return detailApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return DetailApiData(
          message: 'Oops! Something went wrong.',
          status: false,
          ticketDetails: TicketDetails(
            id:0,
            ticketNo:'',
            customerId:0,
            productName:'',
            productSku:'',
            invoiceNo:'',
            invoiceDate:DateTime.now(),
            remark:'',
            status:0,
            oldPartStatus:0,
            createdAt:'',
            files:[],
            motoComments:[],
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
      appBar: const globals.AppBarItems('Warranty Details'),
      body: Center(
        child: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : detailApiData.ticketDetails.id == 0
                  ? const Center(child: Text('No Data'))
                  :Text(detailApiData.ticketDetails.invoiceNo),
      )
    );
  }
}


DetailApiData detailApiDataFromJson(String str) => DetailApiData.fromJson(json.decode(str));

String detailApiDataToJson(DetailApiData data) => json.encode(data.toJson());

class DetailApiData {
    bool status;
    String message;
    TicketDetails ticketDetails;

    DetailApiData({
        required this.status,
        required this.message,
        required this.ticketDetails,
    });

    factory DetailApiData.fromJson(Map<String, dynamic> json) => DetailApiData(
        status: json["status"],
        message: json["message"],
        ticketDetails: TicketDetails.fromJson(json["ticket_details"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "ticket_details": ticketDetails.toJson(),
    };
}

class TicketDetails {
    int id;
    String ticketNo;
    int customerId;
    String productName;
    String productSku;
    String invoiceNo;
    DateTime invoiceDate;
    String remark;
    int status;
    int oldPartStatus;
    String createdAt;
    List<FileElement> files;
    List<MotoComment> motoComments;

    TicketDetails({
        required this.id,
        required this.ticketNo,
        required this.customerId,
        required this.productName,
        required this.productSku,
        required this.invoiceNo,
        required this.invoiceDate,
        required this.remark,
        required this.status,
        required this.oldPartStatus,
        required this.createdAt,
        required this.files,
        required this.motoComments,
    });

    factory TicketDetails.fromJson(Map<String, dynamic> json) => TicketDetails(
        id: json["id"],
        ticketNo: json["ticket_no"],
        customerId: json["customer_id"],
        productName: json["product_name"],
        productSku: json["product_sku"],
        invoiceNo: json["invoice_no"],
        invoiceDate: DateTime.parse(json["invoice_date"]),
        remark: json["remark"],
        status: json["status"],
        oldPartStatus: json["old_part_status"],
        createdAt: json["created_at"],
        files: List<FileElement>.from(json["files"].map((x) => FileElement.fromJson(x))),
        motoComments: List<MotoComment>.from(json["moto_comments"].map((x) => MotoComment.fromJson(x))),
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
        "status": status,
        "old_part_status": oldPartStatus,
        "created_at": createdAt,
        "files": List<dynamic>.from(files.map((x) => x.toJson())),
        "moto_comments": List<dynamic>.from(motoComments.map((x) => x.toJson())),
    };
}

class FileElement {
    int id;
    String fileName;
    String filePath;

    FileElement({
        required this.id,
        required this.fileName,
        required this.filePath,
    });

    factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        fileName: json["file_name"],
        filePath: json["file_path"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "file_name": fileName,
        "file_path": filePath,
    };
}

class MotoComment {
    int id;
    String comment;
    int type;
    String createdAt;

    MotoComment({
        required this.id,
        required this.comment,
        required this.type,
        required this.createdAt,
    });

    factory MotoComment.fromJson(Map<String, dynamic> json) => MotoComment(
        id: json["id"],
        comment: json["comment"],
        type: json["type"],
        createdAt: json["created_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "type": type,
        "created_at": createdAt,
    };
}
