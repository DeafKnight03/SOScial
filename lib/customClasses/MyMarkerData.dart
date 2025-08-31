
import 'package:flutter_map/flutter_map.dart';

class MyMarkerData {
  final String id;
  final String type;
  final String description;
  final int intensity;
  final DateTime date;
  final String place;
  final Marker marker;


  MyMarkerData({
    required this.id,
    required this.type,
    required this.description,
    required this.intensity,
    required this.date,
    required this.place,
    required this.marker,
  });


}