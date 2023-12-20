import 'package:cloud_firestore/cloud_firestore.dart';
class VendorModel {
  String? vid;
  String? email;
  String? facilityName;
  String? ownerName;
  int? bikeCapacity;
  int? carCapacity;
  int? maxCapacity; // Calculated based on bikeCapacity and carCapacity
  GeoPoint? location;
  int? currentBikeFilled; // New field
  int? currentCarFilled;  // New field
  num? currentFilled;  // Sum of currentBikeFilled and currentCarFilled
  String? address;
  String? aadhaar;
  int? bikeBasePrice;
  int? carBasePrice;
  int? dailyEarning;
  int? TodayVisit;
  Timestamp? lastVisitDate; // New field
  int? vehicleEntryRate;
  String? vendorType;
  String? description;
  int? leastFilled; // New field
  Timestamp? leastFilledDate; // New field
  int? changeCounter;
 Map<String, dynamic>? monThurHour;
  Map<String, dynamic>? friSatHour;
  VendorModel({
    this.vid,
    this.email,
    this.facilityName,
    this.ownerName,
    this.bikeCapacity,
    this.carCapacity,
    this.location,
    this.currentBikeFilled,
    this.currentCarFilled,
    this.address,
    this.aadhaar,
    this.bikeBasePrice,
    this.carBasePrice,
    this.dailyEarning,
    this.TodayVisit,
    this.lastVisitDate,
    this.vehicleEntryRate,
    this.vendorType,
    this.description,
    this.leastFilledDate,
    this.changeCounter,
     this.monThurHour,
    this.friSatHour,
  }) { maxCapacity = (bikeCapacity ?? 0) + (carCapacity ?? 0);
       currentFilled = (currentBikeFilled ?? 0) + (currentCarFilled ?? 0);
        leastFilled = maxCapacity; 
  }
  factory VendorModel.fromMap(map) {
    return VendorModel(
      vid: map['vid'],
      email: map['email'],
      facilityName: map['facilityName'],
      ownerName: map['ownerName'],
      bikeCapacity: map['bikeCapacity'],
      carCapacity: map['carCapacity'],
      location: map['location'] as GeoPoint,
      currentBikeFilled: map['currentBikeFilled'],
      currentCarFilled: map['currentCarFilled'],
      address: map['address'],
      aadhaar: map['aadhaar'],
      bikeBasePrice: map['bikeBasePrice'],
      carBasePrice: map['carBasePrice'],
      dailyEarning: map['dailyEarning'],
      TodayVisit: map['TodayVisit'],
      lastVisitDate: map['lastVisitDate'],
      vehicleEntryRate: map['vehicleEntryRate'],
      vendorType: map['vendorType'],
      description: map['description'],
      monThurHour: map['MonThurHour'],
      friSatHour: map['FriSatHour'],
      leastFilledDate: map['leastFilledDate'],
      changeCounter: map['changeCounter'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vid': vid,
      'email': email,
      'facilityName': facilityName,
      'ownerName': ownerName,
      'bikeCapacity': bikeCapacity,
      'carCapacity': carCapacity,
      'maxCapacity': maxCapacity,
      'location': location,
      'currentBikeFilled': currentBikeFilled,
      'currentCarFilled': currentCarFilled,
      'address': address,
      'aadhaar': aadhaar,
      'bikeBasePrice': bikeBasePrice,
      'carBasePrice': carBasePrice,
      'dailyEarning': dailyEarning,
      'TodayVisit': TodayVisit,
      'lastVisitDate': lastVisitDate,
      'vehicleEntryRate': vehicleEntryRate,
      'vendorType': vendorType,
      'description': description,
      'leastFilled': leastFilled, // Include the new fields in the map
      'leastFilledDate': leastFilledDate,
      'changeCounter': changeCounter,
      'MonThurHour': monThurHour,
      'FriSatHour': friSatHour,
    };
  }


}
