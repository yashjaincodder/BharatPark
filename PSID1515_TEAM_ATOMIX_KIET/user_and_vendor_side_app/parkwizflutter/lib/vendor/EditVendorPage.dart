import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkwizflutter/model/vendor_model.dart';

class EditVendorPage extends StatefulWidget {
  final VendorModel vendor;

  EditVendorPage({required this.vendor});

  @override
  _EditVendorPageState createState() => _EditVendorPageState();
}

class _EditVendorPageState extends State<EditVendorPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facilityNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _bikeCapacityController = TextEditingController();
  final TextEditingController _carCapacityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bikeBasePriceController = TextEditingController();
  final TextEditingController _carBasePriceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values
    _emailController.text = widget.vendor.email ?? "";
    _facilityNameController.text = widget.vendor.facilityName ?? "";
    _ownerNameController.text = widget.vendor.ownerName ?? "";
    _bikeCapacityController.text = widget.vendor.bikeCapacity?.toString() ?? "";
    _carCapacityController.text = widget.vendor.carCapacity?.toString() ?? "";
    _descriptionController.text = widget.vendor.description ?? "";
    _bikeBasePriceController.text = widget.vendor.bikeBasePrice?.toString() ?? "";
    _carBasePriceController.text = widget.vendor.carBasePrice?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vendor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _updateVendor();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _facilityNameController,
              decoration: const InputDecoration(labelText: 'Facility Name'),
            ),
            TextField(
              controller: _ownerNameController,
              decoration: const InputDecoration(labelText: 'Owner Name'),
            ),
            TextField(
              controller: _bikeCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Bike Capacity'),
            ),
            TextField(
              controller: _carCapacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Car Capacity'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _bikeBasePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Bike Base Price'),
            ),
            TextField(
              controller: _carBasePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Car Base Price'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateVendor() async {
    // Update the vendor object with new values
    widget.vendor.email = _emailController.text;
    widget.vendor.facilityName = _facilityNameController.text;
    widget.vendor.ownerName = _ownerNameController.text;
    widget.vendor.bikeCapacity = int.tryParse(_bikeCapacityController.text) ?? 0;
    widget.vendor.carCapacity = int.tryParse(_carCapacityController.text) ?? 0;
    widget.vendor.description = _descriptionController.text;
    widget.vendor.bikeBasePrice = int.tryParse(_bikeBasePriceController.text) ?? 0;
    widget.vendor.carBasePrice = int.tryParse(_carBasePriceController.text) ?? 0;

    // Update the document in Firestore
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.vendor.vid)
        .update(widget.vendor.toMap());
  }
}
