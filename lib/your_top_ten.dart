import 'package:flutter/material.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';




class YourTopTen extends StatefulWidget {
  const YourTopTen({super.key});

  @override
  State<YourTopTen> createState() => _YourTopTenState();
}

class _YourTopTenState extends State<YourTopTen> {
  String apiToken = '', errMessage = '';
  late ProductsListApiData productsListApiData;
  bool isLoaded = false;
  List blanklist = List.filled(10, null, growable: true);
  List _isCartDisabled = List.filled(10, null, growable: true);

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    productsListApiData = await getProducts();
  }

  Future<ProductsListApiData> getProducts() async {
    final response =
        await http.post(Uri.https(globals.baseURL, "/api/your-top-10"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $apiToken'
            },
            body: jsonEncode({}));
    var resCode = response.statusCode;
    setState(() {
      isLoaded = true;
    });
    if (resCode == 200) {
      ProductsListApiData productsListApiData =
          productsListApiDataFromJson(response.body);
      setState(() {
        _isCartDisabled = blanklist;
      });
      return productsListApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return ProductsListApiData(
          message: 'Oops! Something went wrong.', products: []);
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
      "product_id": productsListApiData.products[index].productId,
      "variant_id": productsListApiData.products[index].variantId,
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
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(14, 29, 48, 1),
        title: const Text('Top 10 Purchases'),
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
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : productsListApiData.products.isEmpty
                  ? const Center(child: Text('No Data'))
                  : ListView.builder(
                      itemCount: productsListApiData.products.length,
                      itemBuilder: (context, index) => getProductRow(index)),
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
                    image: NetworkImage(productsListApiData.products[index].product.imageSrc),
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
                          productsListApiData.products[index].product.title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Variant: ${productsListApiData.products[index].title}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "SKU: ${productsListApiData.products[index].sku}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Vendor: ${productsListApiData.products[index].product.vendor}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹ ${productsListApiData.products[index].price}",
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


ProductsListApiData productsListApiDataFromJson(String str) => ProductsListApiData.fromJson(json.decode(str));

String productsListApiDataToJson(ProductsListApiData data) => json.encode(data.toJson());

class ProductsListApiData {
    String message;
    List<ProductElement> products;
    // Customer customer;

    ProductsListApiData({
        required this.message,
        required this.products,
        // required this.customer,
    });

    factory ProductsListApiData.fromJson(Map<String, dynamic> json) => ProductsListApiData(
        message: json["message"],
        products: List<ProductElement>.from(json["products"].map((x) => ProductElement.fromJson(x))),
        // customer: Customer.fromJson(json["customer"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        // "customer": customer.toJson(),
    };
}

class ProductElement {
    int id;
    int productId;
    int inventoryItemId;
    int variantId;
    String title;
    String price;
    String? sku;
    int inventoryQuantity;
    int storeId;
    String lifetimeQuantity;
    ProductProduct product;

    ProductElement({
        required this.id,
        required this.productId,
        required this.inventoryItemId,
        required this.variantId,
        required this.title,
        required this.price,
        this.sku,
        required this.inventoryQuantity,
        required this.storeId,
        required this.lifetimeQuantity,
        required this.product,
    });

    factory ProductElement.fromJson(Map<String, dynamic> json) => ProductElement(
        id: json["id"],
        productId: json["product_id"],
        inventoryItemId: json["inventory_item_id"],
        variantId: json["variant_id"],
        title: json["title"],
        price: json["price"],
        sku: json["sku"]??'',
        inventoryQuantity: json["inventory_quantity"],
        storeId: json["store_id"],
        lifetimeQuantity: json["lifetime_quantity"],
        product: ProductProduct.fromJson(json["product"]),
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
        "lifetime_quantity": lifetimeQuantity,
        "product": product.toJson(),
    };
}

class ProductProduct {
    int id;
    String title;
    String vendor;
    String productType;
    String handle;
    String imageSrc;
    int status;
    int storeId;

    ProductProduct({
        required this.id,
        required this.title,
        required this.vendor,
        required this.productType,
        required this.handle,
        required this.imageSrc,
        required this.status,
        required this.storeId,
    });

    factory ProductProduct.fromJson(Map<String, dynamic> json) => ProductProduct(
        id: json["id"],
        title: json["title"],
        vendor: json["vendor"],
        productType: json["product_type"],
        handle: json["handle"],
        imageSrc: json["image_src"],
        status: json["status"],
        storeId: json["store_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "vendor": vendor,
        "product_type": productType,
        "handle": handle,
        "image_src": imageSrc,
        "status": status,
        "store_id": storeId,
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
