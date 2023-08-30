import 'package:flutter/material.dart';
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  String apiToken = '', errMessage = '';
  late CartApiData cartApiData;
  bool isLoaded = false;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString("apiToken") ?? '';
    });
    cartApiData = await getCart();
    setState(() {
      isLoaded = true;
    });
  }

  Future<CartApiData> getCart() async {
    final response =
        await http.get(Uri.https(globals.baseURL, "/api/cart"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $apiToken'
    });
    var resCode = response.statusCode;
    if (resCode == 200) {
      CartApiData cartApiData =
          cartApiDataFromJson(response.body);
      return cartApiData;
    } else {
      errorToast('Oops! Something went wrong.');
      setState(() {
        errMessage = 'Oops! Something went wrong.';
      });
      return CartApiData(
          message: 'Oops! Something went wrong.',
          cartItems: []
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
      appBar: const globals.AppBarItems('Cart'),
      body: !isLoaded
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errMessage.isNotEmpty
              ? Center(
                  child: Text(errMessage),
                )
              : cartApiData.cartItems.isEmpty
                  ? const Center(child: Text('No Data'))
                  : ListView.builder(
                      itemCount: cartApiData.cartItems.length,
                      itemBuilder: (context, index) => getItemsRow(index)),
    );
  }

  Widget getItemsRow(int index) {
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
                    image: NetworkImage(cartApiData.cartItems[index].imageSrc),
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
                          cartApiData.cartItems[index].productTitle,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Variant: ${cartApiData.cartItems[index].variant.title}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "SKU: ${cartApiData.cartItems[index].sku}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Vendor: ${cartApiData.cartItems[index].vendor}",
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "₹ ${cartApiData.cartItems[index].price}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                            color: Colors.indigoAccent.shade400
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              // _isCartDisabled[index] == 1 ? null : addToCart(index);
                            },
                            child: Container(
                              height: 35,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.indigoAccent,
                                  borderRadius:
                                  BorderRadius.circular(5)),
                              child: const Center(
                                // child:  _isCartDisabled[index] == 1 ? 
                                // const SizedBox(height: 15, width: 15, child: Center( child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,))) :
                                // const Icon(Icons.add_shopping_cart, color: Colors.white,)
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



CartApiData cartApiDataFromJson(String str) => CartApiData.fromJson(json.decode(str));

String cartApiDataToJson(CartApiData data) => json.encode(data.toJson());

class CartApiData {
    String message;
    List<CartItem> cartItems;

    CartApiData({
        required this.message,
        required this.cartItems,
    });

    factory CartApiData.fromJson(Map<String, dynamic> json) => CartApiData(
        message: json["message"],
        cartItems: List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "cart_items": List<dynamic>.from(cartItems.map((x) => x.toJson())),
    };
}

class CartItem {
    int id;
    int customerId;
    int productId;
    int variantId;
    String sku;
    String price;
    String discountedPrice;
    int quantity;
    int processed;
    String imageSrc;
    String productTitle;
    String vendor;
    String productType;
    String discountText;
    Variant variant;
    Product product;

    CartItem({
        required this.id,
        required this.customerId,
        required this.productId,
        required this.variantId,
        required this.sku,
        required this.price,
        required this.discountedPrice,
        required this.quantity,
        required this.processed,
        required this.imageSrc,
        required this.productTitle,
        required this.vendor,
        required this.productType,
        required this.discountText,
        required this.variant,
        required this.product,
    });

    factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json["id"],
        customerId: json["customer_id"],
        productId: json["product_id"],
        variantId: json["variant_id"],
        sku: json["sku"]??'',
        price: json["price"],
        discountedPrice: json["discounted_price"],
        quantity: json["quantity"],
        processed: json["processed"],
        imageSrc: json["image_src"],
        productTitle: json["product_title"],
        vendor: json["vendor"],
        productType: json["product_type"],
        discountText: json["discount_text"],
        variant: Variant.fromJson(json["variant"]),
        product: Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "product_id": productId,
        "variant_id": variantId,
        "sku": sku,
        "price": price,
        "discounted_price": discountedPrice,
        "quantity": quantity,
        "processed": processed,
        "image_src": imageSrc,
        "product_title": productTitle,
        "vendor": vendor,
        "product_type": productType,
        "discount_text": discountText,
        "variant": variant.toJson(),
        "product": product.toJson(),
    };
}

class Product {
    int id;
    int productId;
    String title;
    String handle;
    String imageSrc;
    int status;
    int storeId;

    Product({
        required this.id,
        required this.productId,
        required this.title,
        required this.handle,
        required this.imageSrc,
        required this.status,
        required this.storeId,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        title: json["title"],
        handle: json["handle"],
        imageSrc: json["image_src"],
        status: json["status"],
        storeId: json["store_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "title": title,
        "handle": handle,
        "image_src": imageSrc,
        "status": status,
        "store_id": storeId,
    };
}

class Variant {
    int id;
    int inventoryItemId;
    String title;
    int inventoryQuantity;
    int storeId;
    Product product;

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
