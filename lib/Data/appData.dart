import 'package:flutter/cupertino.dart';
import 'package:uberapp_clone/Models/address.dart';

class AppData extends ChangeNotifier {
  Address? pickupLocation, dropOffLocation;

  void updatePickupLocation(Address? pickupAddress) {
    pickupLocation = pickupAddress;
    notifyListeners();
  }

  void updateWheretoLocation(Address? wheretoAddress) {
    dropOffLocation = wheretoAddress;
    notifyListeners();
  }
}
