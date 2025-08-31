import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'map.dart';
import 'sendSignal.dart';

class MapPage extends StatefulWidget {


  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
   LatLng? location = LatLng(41.9028, 12.4964); // Example coordinates (Rome)
   String? placeName = "Roma"; // Example place name

  int state = 0;
  void _changeState(int newState, LatLng? location, String? placeName) {
    if(newState == 1){
      setState(() {
      this.location = location;
      this.placeName = placeName;
      state = newState;
    });
    }else{
      setState(() {
        state = newState;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return (state == 0) ? Map(changeState: _changeState) : Sendsignal(changeState: _changeState, location: location, placeName: placeName);
  }
}

    
