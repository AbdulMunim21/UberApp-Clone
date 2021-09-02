import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uberapp_clone/Data/appData.dart';
import 'package:uberapp_clone/Models/address.dart';
import 'package:uberapp_clone/Models/place_prediction.dart';
import 'package:uberapp_clone/constants/mapkey.dart';
import 'package:uberapp_clone/helper/helper_methods.dart';
import 'package:uberapp_clone/helper/requestHelper.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "search-screen";
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

TextEditingController _dropoffController = TextEditingController();

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _pickupController = TextEditingController();

  List<PlacePrediction> predictionList = [];

  @override
  Widget build(BuildContext context) {
    final place =
        Provider.of<AppData>(context).pickupLocation?.placeFormatAddress ?? "";
    _pickupController.text = place;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 215,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.arrow_back),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Center(
                          child: Text(
                            "Set Drop Off",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: TextFormField(
                                controller: _pickupController,
                                decoration: InputDecoration(
                                  hintText: "PickUp Location",
                                  fillColor: Colors.grey.shade400,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/desticon.png',
                          height: 25,
                          width: 25,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: TextFormField(
                                controller: _dropoffController,
                                onChanged: (value) {
                                  findPlace(value);
                                },
                                decoration: InputDecoration(
                                  hintText: "Drop Off Location",
                                  fillColor: Colors.grey.shade400,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (predictionList.isNotEmpty)
              Expanded(
                child: Container(
                  child: ListView(
                      children: predictionList.map((e) {
                    return PredictionTile(e);
                  }).toList()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=establishment&radius=500&key=$mapkey&components=country:pk";
      final result = await RequestHelper.getRequest(autoCompleteUrl);

      if (result == 'Error') {
        return;
      }

      if (result['status'] == 'OK') {
        var predictions = result['predictions'];

        var placeList = (predictions as List).map((e) {
          return PlacePrediction.fromJSON(e);
        }).toList();

        setState(() {
          predictionList = placeList;
        });
      }

      print(result);
    }
  }
}

class PredictionTile extends StatelessWidget {
  late final PlacePrediction placePrediction;

  PredictionTile(placePrediction) {
    this.placePrediction = placePrediction;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        getPlaceAddressDetails(placePrediction.place_id, context);
      },
      leading: Icon(Icons.add_location),
      title: Text(placePrediction.main_text),
      subtitle: Text(placePrediction.secondary_text),
    );
  }

  void getPlaceAddressDetails(String place_id, BuildContext context) async {
    String detail_url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=$mapkey";

    var res = await RequestHelper.getRequest(detail_url);

    if (res == "Error") {
      return;
    }

    if (res['status'] == "OK") {
      final placeformatAddress = res['result']['formatted_address'];
      final placeName = res['result']['address_components'][2]['long_name'];
      final placeId = place_id;
      final latitude = res['result']['geometry']['location']['lat'];
      final longitude = res['result']['geometry']['location']['lng'];
      Address address =
          Address(placeformatAddress, placeName, placeId, latitude, longitude);

      Provider.of<AppData>(context, listen: false)
          .updateWheretoLocation(address);

      _dropoffController.text = Provider.of<AppData>(context, listen: false)
          .dropOffLocation!
          .placeFormatAddress;

      Navigator.of(context).pop("ObtainDirections");
    }
  }
}
