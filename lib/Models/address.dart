class Address {
  late String placeFormatAddress;
  late String placeName;
  late String placeId;
  late double latitude;
  late double longitude;

  Address(placeFormatAddress, placeName, placeId, latitude, longitude) {
    this.placeName = placeName;
    this.placeFormatAddress = placeFormatAddress;
    this.placeId = placeId;
    this.latitude = latitude;
    this.longitude = longitude;
  }
}
