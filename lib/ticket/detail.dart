import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../common/globals.dart' as globals;
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
  String apiToken = '', errMessage = '', lastName = '', firstName = '';
  String? comment = '';
  late DetailApiData detailApiData;
  bool isLoaded = false;
  final _commentKey = GlobalKey<FormState>();

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
      firstName = prefs.getString("firstName") ?? '';
      lastName = prefs.getString("lastName") ?? '';
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
            invoiceDate:'',
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

  void submitComment() async {
    final form = _commentKey.currentState;
    form!.save();
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/warranty-comment"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiToken'
            },
            body: jsonEncode({"ticket_no": widget.ticketNo,"comment": comment}));

    var data = jsonDecode(response.body);
    var resCode = response.statusCode;
    String message = data['message'];
    if (resCode == 200) {
      errorToast('$message !!');
      commentAdded();
    } else {
      errorToast('Oops! Something went wrong.');
    }
  }

  void commentAdded() {
    goToDetails(context);
  }

  void goToDetails(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Detail(widget.ticketNo)));
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
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : detailApiData.ticketDetails.id == 0
                  ? const Center(child: Text('No Data'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: detailApiData.ticketDetails.motoComments.isEmpty ? 1 : detailApiData.ticketDetails.motoComments.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                            return getClaimDetails();
                        }
                        index -= 1;
                        return getCommentsRow(index);
                      }
                    ),
      );
  }

  Widget getCommentsRow(int index) {
    if (index < detailApiData.ticketDetails.motoComments.length) {
      return Container(
        color:const Color.fromRGBO(243, 246, 252, 1),
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: Card(
          elevation: 0,
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: const BoxDecoration(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$firstName $lastName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text(detailApiData.ticketDetails.motoComments[index].createdAt,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10.00
                  ),
                ),
                Text(detailApiData.ticketDetails.motoComments[index].comment),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: const Color.fromRGBO(243, 246, 252, 1),
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Form(
          key: _commentKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Row(
                  children: [
                    Padding(padding: EdgeInsets.only(left: 20.0)),
                    Text('*', style: TextStyle(color: Colors.red),),
                    Text('Add Comment For Support')
                  ],
                ),
                // Notes
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: TextFormField(
                    onSaved: (e) => comment = e,
                    validator: (value) {
                      if (value == null || value.isEmpty) {                                      
                        return 'Please Enter Your Comment';
                      }
                      return null;
                    },
                    maxLines: null,
                    minLines: 3,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: 'Write your comment here.',
                      border: UnderlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                // Checkout Submit  Color.fromRGBO(13, 66, 255, 1),
                Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          submitComment();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(13, 66, 255, 1))),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          child: const Text('Post Comment'),
                        )
                      )
                ),
              ]),
        ),
      );
    }
  }

  Widget getClaimDetails(){
    return  Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(243, 246, 252, 1)
      ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: Text('WARRANTY CLAIM',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text('Form to claim your warranty.'),
                )
              )
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: const Text('INVOICE NUMBER',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.invoiceNo),
                )
              ),
              Expanded(
                child: ListTile(
                  title: const Text('INVOICE DATE',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.invoiceDate),
                )
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: const Text('PRODUCT NAME',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.productName),
                )
              ),
              Expanded(
                child: ListTile(
                  title: const Text('PRODUCT SKU',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.productSku),
                )
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: const Text('YOUR REMARK',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.remark),
                )
              ),
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: const Text('UPLOADED FILES',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: 
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            for(var i = 0; i< detailApiData.ticketDetails.files.length; i++)
                              ...[
                                TextSpan( text: '${(i+1).toString()}: ', style: const TextStyle(color: Colors.black)),                                                
                                TextSpan( 
                                  text: '${detailApiData.ticketDetails.files[i].fileName} \n',
                                  style: const TextStyle(color:Color.fromRGBO(13, 66, 255, 1)),
                                  recognizer: TapGestureRecognizer()..onTap = () async {
                                    List<String> substrings = detailApiData.ticketDetails.files[i].fileName.split(".");
                                    List<String> imgExt = ['jpeg', 'jpg', 'png'];
                                      if (imgExt.contains(substrings.last)) {
                                        await showDialog(
                                          context: context,
                                          builder: (_) => imageDialog(detailApiData.ticketDetails.files[i].fileName, 'https://${globals.baseURL}/public/${detailApiData.ticketDetails.files[i].filePath+detailApiData.ticketDetails.files[i].fileName}', context)
                                        );
                                      }else if( substrings[1] == 'pdf'){
                                        
                                      }
                                    }
                                ),
                              ],
                          ],
                        ),
                      )
                )
              ),
              Expanded(
                child: ListTile(
                  title: const Text('STATUS',style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.0,
                  letterSpacing: 1.2,
                ),),
                  subtitle: Text(detailApiData.ticketDetails.status == 0 ? 'Open' : 'Closed'),
                )
              ),
            ]
          ),
          const Divider(
            color: Colors.black87,
            thickness: 0.1,
            indent: 20.0,
            endIndent: 20.0,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left:15)),
              Expanded(
                child: ListTile(
                  title: Text('COMMENTS BY MOTOUSHER SUPPORT:',style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    letterSpacing: 1.2,
                  ),),
                )
              ),
            ]
          ),
        ]
      ),
    );
  }

  Widget imageDialog(text, path, context) {
    return Dialog(
      // backgroundColor: Colors.transparent,
      // elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$text',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
          SizedBox(
            child: Image.network(
              '$path',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
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
    String invoiceDate;
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
        invoiceDate: json["invoice_date"],
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
        "invoice_date": invoiceDate,
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
