import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map<String, dynamic>> products = [
    {
      "name": "Samba",
      "quantity": "120",
      "price": "120",
      "area": "2 acres",
      "harvestDate": "15-Aug-2025",
      "status": "Available",
      "image": "assets/samba.png",
      "isAsset": true,
    },
    {
      "name": "Naadu (Red)",
      "quantity": "80",
      "price": "100",
      "area": "3 acres",
      "harvestDate": "05-Jul-2025",
      "status": "Sold Out",
      "image": "assets/red_naadu.png",
      "isAsset": true,
    },
  ];

  final ImagePicker _picker = ImagePicker();

  void _addOrEditProduct({Map<String, dynamic>? product, int? index}) {
    final nameController = TextEditingController(text: product?["name"] ?? "");
    final quantityController = TextEditingController(
      text: product?["quantity"] ?? "",
    );
    final priceController = TextEditingController(
      text: product?["price"] ?? "",
    );
    final areaController = TextEditingController(text: product?["area"] ?? "");
    final harvestDateController = TextEditingController(
      text: product?["harvestDate"] ?? "",
    );
    String status = product?["status"] ?? "Available";
    File? selectedImage;

    String? assetImage = (product != null && product["isAsset"] == true)
        ? product["image"]
        : null;

    final scrollController = ScrollController();

    // FocusNodes for automatic scrolling
    final nameFocus = FocusNode();
    final quantityFocus = FocusNode();
    final priceFocus = FocusNode();
    final areaFocus = FocusNode();
    final harvestFocus = FocusNode();

    void scrollToFocus(FocusNode node) {
      node.addListener(() {
        if (node.hasFocus) {
          // Scroll slightly above the field
          scrollController.animateTo(
            scrollController.position.pixels + 80,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    scrollToFocus(nameFocus);
    scrollToFocus(quantityFocus);
    scrollToFocus(priceFocus);
    scrollToFocus(areaFocus);
    scrollToFocus(harvestFocus);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(product == null ? "Add Product" : "Edit Product"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image with edit pen
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setStateDialog(() {
                              selectedImage = File(pickedFile.path);
                              assetImage = null;
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: selectedImage != null
                                  ? Image.file(
                                      selectedImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : (assetImage != null
                                        ? Image.asset(
                                            assetImage!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.teal,
                                            ),
                                          )),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      TextField(
                        controller: nameController,
                        focusNode: nameFocus,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.teal),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quantity
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: quantityController,
                              focusNode: quantityFocus,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Quantity",
                                labelStyle: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("kg"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              focusNode: priceFocus,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Price",
                                labelStyle: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("Rs/kg"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Area
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: areaController,
                              focusNode: areaFocus,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Area",
                                labelStyle: TextStyle(color: Colors.teal),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("Acres"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Harvest Date
                      TextField(
                        controller: harvestDateController,
                        focusNode: harvestFocus,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Harvest Date",
                          labelStyle: const TextStyle(color: Colors.teal),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.teal,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              harvestDateController.text =
                                  "${picked.day}-${picked.month}-${picked.year}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status
                      DropdownButtonFormField<String>(
                        value: status,
                        items: ["Available", "Sold Out"].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            status = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: "Status",
                          labelStyle: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF009688),
                  ),
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                  onPressed: () {
                    final newProduct = {
                      "name": nameController.text,
                      "quantity": quantityController.text,
                      "price": priceController.text,
                      "area": areaController.text,
                      "harvestDate": harvestDateController.text,
                      "status": status,
                      "image":
                          selectedImage?.path ??
                          assetImage ??
                          "assets/default.png",
                      "isAsset": selectedImage == null,
                    };

                    setState(() {
                      if (index != null) {
                        products[index] = newProduct;
                      } else {
                        products.add(newProduct);
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
            onPressed: () {
              setState(() {
                products.removeAt(index);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF009688),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: product["isAsset"] == true
                        ? Image.asset(
                            product["image"],
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(product["image"]),
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product["name"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: product["status"] == "Available"
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product["status"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("Qty: ${product["quantity"]} kg"),
                        Text("Price: Rs. ${product["price"]}/kg"),
                        Text("Area: ${product["area"]}"),
                        Text("Harvest: ${product["harvestDate"]}"),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _addOrEditProduct(
                                product: product,
                                index: index,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditProduct(),
        backgroundColor: const Color(0xFF009688),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
