class Address {
  late String placeName;
  late double latitude;
  late double longitude;
  late String placeId;
  late String placeFormattedAddress;

  Address({
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.placeFormattedAddress,
  });
}
