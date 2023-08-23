import 'package:flutter/material.dart';


class OrderDetail extends StatefulWidget {
  final int orderId;
  const OrderDetail(this.orderId, {super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
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
      body: Text(widget.orderId.toString()),
      // !isLoaded ? const Center(child: CircularProgressIndicator(),):
      // errMessage.isNotEmpty ? Center(child: Text(errMessage),) : ordersListApiData.orders.data.isEmpty ? const Center(child: Text('No Data')) : 
      // ListView.builder(
      //   itemCount: ordersListApiData.orders.data.length,
      //   itemBuilder: (context, index) => getOrderRow(index)
      // ),
    );
  }
}