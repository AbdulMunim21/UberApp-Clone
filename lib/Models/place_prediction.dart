class PlacePrediction {
  late String secondary_text;
  late String main_text;
  late String place_id;

  PlacePrediction(secondary_text, main_text, place_id) {
    this.secondary_text = secondary_text;
    this.main_text = main_text;
    this.place_id = place_id;
  }

  PlacePrediction.fromJSON(Map<String, dynamic> json) {
    place_id = json['place_id'];
    main_text = json['structured_formatting']['main_text'];
    secondary_text = json['structured_formatting']['secondary_text'];
  }
}
