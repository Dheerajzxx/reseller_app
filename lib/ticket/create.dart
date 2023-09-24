import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../common/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reseller_plusgrow/ticket/history.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTicket extends StatefulWidget {
  const AddTicket({super.key});

  @override
  State<AddTicket> createState() => _AddTicketState();
}

class _AddTicketState extends State<AddTicket> {
  String apiToken = '', errMessage = '';
  String? invoiceNo = '', productName = '', productSku = '', remark = '';
  late Products products;
  List skuList = List.filled(0, null, growable: true);
  List productTitleList = List.filled(0, null, growable: true);
  bool _isSaveEnable = true, isLoaded = false;
  final _saveTicketKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  FilePickerResult? ticketFiles;

  void getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    products = await getProducts();
    setState(() {
      isLoaded = true;
    });
  }

  void submitForm() {
    final form = _saveTicketKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      setState(() {
        _isSaveEnable = true;
      });
      saveTicket();
    }
  }

  void saveTicket() async {
    var request = http.MultipartRequest(
        'POST', Uri.https(globals.baseURL, "/api/save-warranty"));
    request.headers.addAll({"Authorization": "Bearer $apiToken"});
    request.fields['invoice_no'] = invoiceNo ?? '';
    request.fields['product_name'] = productName ?? '';
    request.fields['product_sku'] = productSku ?? '';
    request.fields['remark'] = remark ?? '';
    if (ticketFiles != null) {
      ticketFiles?.files.forEach((element) async {
        request.files.add(
            await http.MultipartFile.fromPath(
                'ticket_files[]',
                element.path ?? '',
            )
        );
      });
    }

    var res = await request.send();
    var response = await http.Response.fromStream(res);
    var data = jsonDecode(response.body);
    var resCode = response.statusCode;
    String message = data['message'];
    if (resCode == 200) {
      errorToast('$message !!');
      ticketSaved();
    } else {
      errorToast('Oops! Something went wrong.');
    }
  }

  void ticketSaved() {
    setState(() {
      _isSaveEnable = true;
    });
    _clearCachedFiles();
    goToHistory(context);
  }

  void goToHistory(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TicketsHistory()));
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

  Future<Products> getProducts() async {
    final response = await http
        .get(Uri.https(globals.baseURL, "/api/warranty-products"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    });
    var resCode = response.statusCode;
    if (resCode == 200) {
      Products products = productsFromJson(response.body);
      skuList = products.productVariants;
      productTitleList = products.titles;
      return products;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return Products(
          message: 'Oops! Something went wrong.',
          status: false,
          productVariants: [],
          titles: []);
    }
  }

  void setProductName(sku) {
    _controller.text = productTitleList[skuList.indexOf(sku)].toString();
    setState(() {
      productSku = sku.toString();
    });
  }

  void _clearCachedFiles() async {
    await FilePicker.platform.clearTemporaryFiles();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const globals.AppBarItems('Warranty Claim', '/',1),
        body: !isLoaded
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errMessage.isNotEmpty
                ? Center(
                    child: Text(errMessage),
                  )
                : products.productVariants.isEmpty
                    ? const Center(child: Text('No Data'))
                    : SingleChildScrollView(
                        child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(243, 246, 252, 1)),
                            child: Form(
                              key: _saveTicketKey,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 15)),
                                          Expanded(
                                              child: ListTile(
                                            title: Text(
                                              'CREATE WARRANTY CLAIM',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.0,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            subtitle: Text(
                                                'Fill all the required details to claim your warranty.'),
                                          ))
                                        ]),
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('Referrence '),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 5)),
                                    // invoiceNo
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 0, left: 30, right: 30),
                                      child: TextFormField(
                                        onSaved: (e) => invoiceNo = e,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Referrence Details.';
                                          }
                                          return null;
                                        },
                                        maxLines: null,
                                        minLines: 3,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          hintText:
                                              'Order Date, Purchase Invoice No, Sale Invoice No , etc.',
                                          border: UnderlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20)),
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('Product SKU '),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 5)),
                                    // product SKU
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 30, right: 30),
                                      color: Colors.white,
                                      child: DropdownSearch<dynamic>(
                                        items: skuList,
                                        popupProps: const PopupProps.menu(
                                          showSearchBox: true,
                                        ),
                                        onChanged: (v) {
                                          setProductName(v);
                                        },
                                        validator: (value) {
                                          if (value == null ||
                                              value.toString().isEmpty) {
                                            return 'Please Slect Product SKU';
                                          }
                                          return null;
                                        },
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                                  hintText:
                                                      "Select Product SKU",
                                                  fillColor: Colors.amber,
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          10, 15, 0, 0)),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20)),
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('Product Name '),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 5)),
                                    // product name
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 0, left: 30, right: 30),
                                      child: TextFormField(
                                        controller: _controller,
                                        onSaved: (e) => productName = e,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Product Name';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          hintText: 'Product Name',
                                          border: UnderlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20)),
                                    // remark
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('YOUR REMARK ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              letterSpacing: 1.2,
                                            )),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10)),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 0,
                                          left: 30,
                                          right: 30,
                                          bottom: 20),
                                      child: TextFormField(
                                        onSaved: (e) => remark = e,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Your Remark';
                                          }
                                          return null;
                                        },
                                        maxLines: null,
                                        minLines: 5,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          hintText: 'Message',
                                          border: UnderlineInputBorder(),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('UPLOAD FILES ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              letterSpacing: 1.2,
                                            )),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    const Row(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                left: 30.0, bottom: 5)),
                                        Text('You can upload up to 5 Files'),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 30, top:10),
                                          child: Row( children: [
                                          ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        const Color.fromRGBO(
                                                            13, 66, 255, 1))),
                                            onPressed: () async {
                                              ticketFiles = await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                allowMultiple: true,
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  'jpg',
                                                  'pdf'
                                                ],
                                              );
                                              if (ticketFiles == null) {
                                                errorToast("No file selected");
                                              } else {
                                                setState(() {});
                                              }
                                            },
                                            child: const Text("Upload Files"),
                                          ),]),
                                        ),
                                        if (ticketFiles != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8.0,
                                                left: 30.0,
                                                right: 30),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Selected files:',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: ticketFiles
                                                            ?.files.length ??
                                                        0,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                          ticketFiles
                                                                  ?.files[index]
                                                                  .name ??
                                                              '',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold));
                                                    })
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 20)),
                                    // submit
                                    Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _isSaveEnable
                                                  ? submitForm()
                                                  : null;
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        const Color.fromRGBO(
                                                            13, 66, 255, 1))),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child:
                                                  const Text('Create Ticket'),
                                            ))),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 40)),
                                  ]),
                            ))));
  }
}

Products productsFromJson(String str) => Products.fromJson(json.decode(str));

String productsToJson(Products data) => json.encode(data.toJson());

class Products {
  bool status;
  String message;
  List<ProductVariant> productVariants;
  List<Titles> titles;

  Products({
    required this.status,
    required this.message,
    required this.productVariants,
    required this.titles,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        status: json["status"],
        message: json["message"],
        productVariants: List<ProductVariant>.from(
            json["product_variants"].map((x) => ProductVariant.fromJson(x))),
        titles: List<Titles>.from(
            json["product_variants"].map((x) => Titles.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "product_variants":
            List<dynamic>.from(productVariants.map((x) => x.toJson())),
        "titles": List<dynamic>.from(productVariants.map((x) => x.toJson())),
      };
}

class Titles {
  Product product;

  Titles({required this.product});

  factory Titles.fromJson(Map<String, dynamic> json) => Titles(
        product: Product.fromJson(json["product"]),
      );

  Map<String, dynamic> toJson() => {
        "product": product.toJson(),
      };

  @override
  String toString() => product.title;
}

class ProductVariant {
  int productId;
  int variantId;
  String sku;
  Product product;

  ProductVariant({
    required this.productId,
    required this.variantId,
    required this.sku,
    required this.product,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        productId: json["product_id"],
        variantId: json["variant_id"],
        sku: json["sku"],
        product: Product.fromJson(json["product"]),
      );

  static List<ProductVariant> fromJsonList(List list) {
    return list.map((item) => ProductVariant.fromJson(item)).toList();
  }

  String productAsString() {
    return sku;
  }

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "variant_id": variantId,
        "sku": sku,
        "product": product.toJson(),
      };

  @override
  String toString() => sku;
}

class Product {
  int id;
  String title;

  Product({
    required this.id,
    required this.title,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}
