class DirectionDetails {
  late int distanceValue;
  late int durationValue;
  late String distanceText;
  late String durationText;
  late String encodedPoints;

  DirectionDetails(
      distanceText, distanceValue, durationText, durationValue, encodedPoints) {
    this.distanceText = distanceText;
    this.distanceValue = distanceValue;
    this.durationText = durationText;
    this.durationValue = durationValue;
    this.encodedPoints = encodedPoints;
  }
}
