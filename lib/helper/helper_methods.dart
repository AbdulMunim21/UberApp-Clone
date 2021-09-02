import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uberapp_clone/Data/appData.dart';
import 'package:uberapp_clone/Models/address.dart';
import 'package:uberapp_clone/Models/direction_details.dart';
import 'package:uberapp_clone/constants/mapkey.dart';
import 'package:uberapp_clone/helper/requestHelper.dart';

class HelperMethods {
  static Future<String> searchCoordinatesAddress(
      Position position, BuildContext context) async {
    String placeAddress = '';
    String url =
        await 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey';

    var response = await RequestHelper.getRequest(url);

    print("URL Data : $response");

    if (response != "Error") {
      placeAddress = response["results"][0]['formatted_address'];
      final placeName =
          response["results"][0]['address_components'][3]['long_name'];
      final placeId = response["results"][0]['place_id'];
      Address address = Address(
        placeAddress,
        placeName,
        placeId,
        position.latitude,
        position.longitude,
      );

      Provider.of<AppData>(context, listen: false)
          .updatePickupLocation(address);
    }

    return placeAddress;
  }

  static Future<dynamic> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapkey";
    var res = await RequestHelper.getRequest(directionUrl);
    if (res == "Error") {
      return null;
    }
    var distanceText = res['routes'][0]['legs'][0]['distance']['text'];
    var distanceValue = res['routes'][0]['legs'][0]['distance']['value'];
    var durationText = res['routes'][0]['legs'][0]['duration']['text'];
    var durationValue = res['routes'][0]['legs'][0]['duration']['value'];
    var encodedPoints = res['routes'][0]['overview_polyline']['points'];
    DirectionDetails details = DirectionDetails(distanceText, distanceValue,
        durationText, durationValue, encodedPoints);

    return details;
  }

  static double calculateFair(DirectionDetails details) {
    double timeTraveledFair = (details.durationValue / 60) *
        0.3; //* per each minute, charging 0.3 dollars
    double distanceTraveledFair = (details.distanceValue / 1000) *
        0.5; //* per each km, charging 0.5 dollars
    double total = timeTraveledFair + distanceTraveledFair;

    double totalLocalAmount = total * 160;

    return totalLocalAmount;
  }
}
