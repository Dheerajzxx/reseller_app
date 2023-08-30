import 'package:flutter/material.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class QuickOrder extends StatefulWidget {
  const QuickOrder({super.key});

  @override
  State<QuickOrder> createState() => _QuickOrderState();
}

class _QuickOrderState extends State<QuickOrder> {
  String apiToken = '', errMessage = '';
  String? search = '';
  TextEditingController editingController = TextEditingController();
  late QuickOrderApiData quickOrderApiData;
  bool isLoaded = false;
  Timer? _debounce;

  List newlist = List.filled(10, null, growable: true);
  List blanklist = List.filled(10, null, growable: true);
  List _isCartDisabled = List.filled(10, null, growable: true);

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    quickOrderApiData = await getProducts();
  }

  void filterSearchResults(String query) {
    if (query.length > 2) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        setState(() {
          isLoaded = false;
          search = query;
        });
        getProducts();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<QuickOrderApiData> getProducts() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/quick-order"),
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
      QuickOrderApiData quickOrderApiData =
          quickOrderApiDataFromJson(response.body);
      setState(() {
        _isCartDisabled = blanklist;
        newlist = quickOrderApiData.productVariants;
      });
      return quickOrderApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return QuickOrderApiData(
          message: 'Oops! Something went wrong.', productVariants: []);
    }
  }

  void addToCart(index) async {
    setState(() {
      _isCartDisabled[index] = 1;
    });
    var response = await http.post(Uri.https(globals.baseURL,"/api/add-to-cart"),headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken'
        }, body: jsonEncode({
      "product_id": newlist[index].productId,
      "variant_id": newlist[index].variantId,
    }));

    var addCartData = jsonDecode(response.body);
    var resCode = response.statusCode;
    
    String message = addCartData['message'];
    if (resCode == 200) {
      errorToast(message);
    }else{
      errorToast('Oops! Product not added to cart.');
    }
    setState(() {
       _isCartDisabled[index] = null;
    });
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
      appBar: const globals.AppBarItems('Quick Order'),
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
                    labelText: "Search",
                    hintText: "Search",
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
                      : quickOrderApiData.productVariants.isEmpty
                          ? const Center(child: Text('No Data Found!!'))
                          : ListView.builder(
                              itemCount: newlist.length,
                              itemBuilder: (context, index) =>
                                  getProductRow(index)),
            ),
          ],
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image(
                    height: 100,
                    width: 100,
                    image: NetworkImage(newlist[index].imageSrc),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newlist[index].product.title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Variant: ${newlist[index].title}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "SKU: ${newlist[index].sku}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Vendor: ${newlist[index].vendor}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹ ${newlist[index].price}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                            color: Colors.indigoAccent.shade400
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              _isCartDisabled[index] == 1 ? null : addToCart(index);
                            },
                            child: Container(
                              height: 35,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.indigoAccent,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: Center(
                                child:  _isCartDisabled[index] == 1 ? 
                                const SizedBox(height: 15, width: 15, child: Center( child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))) :
                                const Icon(Icons.add_shopping_cart, color: Colors.white,)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

QuickOrderApiData quickOrderApiDataFromJson(String str) =>
    QuickOrderApiData.fromJson(json.decode(str));

String quickOrderApiDataToJson(QuickOrderApiData data) =>
    json.encode(data.toJson());

class QuickOrderApiData {
  String message;
  List<ProductVariant> productVariants;

  QuickOrderApiData({
    required this.message,
    required this.productVariants,
  });

  factory QuickOrderApiData.fromJson(Map<String, dynamic> json) =>
      QuickOrderApiData(
        message: json["message"],
        productVariants: List<ProductVariant>.from(
            json["product_variants"].map((x) => ProductVariant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "product_variants":
            List<dynamic>.from(productVariants.map((x) => x.toJson())),
      };
}

class ProductVariant {
  int id;
  int productId;
  int inventoryItemId;
  int variantId;
  String title;
  String price;
  String sku;
  int inventoryQuantity;
  int storeId;
  String imageSrc;
  String productTitle;
  String vendor;
  String productType;
  String discountText;
  Product product;

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
  int id;
  int productId;
  String title;
  String publishedScope;
  int status;
  int storeId;

  Product({
    required this.id,
    required this.productId,
    required this.title,
    required this.publishedScope,
    required this.status,
    required this.storeId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        title: json["title"],
        publishedScope: json["published_scope"],
        status: json["status"],
        storeId: json["store_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "title": title,
        "published_scope": publishedScope,
        "status": status,
        "store_id": storeId,
      };
}
