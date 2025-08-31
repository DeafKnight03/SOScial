import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../../customClasses/MyMarkerData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/main.dart';

class Map extends StatefulWidget {
  final void Function(int, LatLng?, String?) changeState;
  const Map({super.key, required this.changeState});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  bool tmp = false;
  Marker localMarker = Marker(
    point: LatLng(44.4949, 111.3426), // Bologna
    width: 40,
    height: 40,
    child: const Icon(Icons.location_on, color: Colors.red),
  );

  var placeName = '';
  final PopupController _popupController = PopupController();
  final PopupController _popupController2 = PopupController();

  Widget _buildElevatedButton(String id) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("removals").doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        bool check = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          // Document exists, you can access its data
          var data = snapshot.data!;
          List<String> nRemovals = List<String>.from(data['nRemovals'] ?? []);
          nRemovals.contains(FirebaseAuth.instance.currentUser!.uid)
              ? check = true
              : check = false;
          // Do something with the data
        } else {
          // Document does not exist
          check = false;
        }
        if (check) {
          return SizedBox.shrink(); // Return null if the button should not be displayed
        }
        return ElevatedButton(
          onPressed: () {
            // Implement remove functionality
            FirebaseFirestore.instance
                .collection('removals')
                .doc(id)
                .update({
                  'nRemovals': FieldValue.arrayUnion([
                    FirebaseAuth.instance.currentUser!.uid,
                  ]),
                })
                .then(
                  (value) => setState(() {
                    tmp = !tmp;
                  }),
                );
            _popupController.hideAllPopups();
            _popupController2.hideAllPopups();
            messengerKey.currentState!
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    "Segnalazione di rimozione inviata con successo!",
                  ),
                  duration: Duration(seconds: 2), // scompare dopo 2 secondi
                ),
              );
          },
          child: const Text('Rimuovi'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(44.4949, 11.3426); // Bologna
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 208, 176),
      appBar: AppBar(
        title: const Text('MAP'),
        backgroundColor: Color.fromARGB(255, 255, 208, 176),
      ),

      body: Column(
        children: [
          // --- MAPPA ---
          Expanded(
            flex: 3, // occupa 3 parti verticali
            child: Row(
              children: [
                const Spacer(flex: 1), // spazio a sinistra
                Expanded(
                  flex: 6,
                  child: Center(
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),

                          child: FlutterMap(
                            options: MapOptions(
                              onTap: (tapPosition, point) async {
                                _popupController.hideAllPopups();
                                _popupController2.hideAllPopups();
                                placeName = await getPlaceName(
                                  point.latitude,
                                  point.longitude,
                                );
                                setState(() {
                                  localMarker = Marker(
                                    point: point,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                    ),
                                  );
                                });
                              },
                              initialCenter: center,
                              initialZoom: 13,
                            ),
                            children: [
                              // 1. Livello delle mappe (tiles)
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.my_app',
                              ),

                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('events')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                    return PopupMarkerLayer(
                                      options: PopupMarkerLayerOptions(
                                        popupController: _popupController,
                                        markers: [],
                                        popupDisplayOptions: PopupDisplayOptions(
                                          builder: (context, marker) {
                                            return Card(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  'Local Marker\n'
                                                  'Point: ${marker.point.latitude}, ${marker.point.longitude}',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  var list = snapshot.data!.docs.map((doc) {
                                    var data = doc.data();
                                    // Do something with the data
                                    return MyMarkerData(
                                      id: doc.id,
                                      type: data['type'] ?? 'No Type',
                                      description:
                                          data['description'] ??
                                          'No Description',
                                      intensity: data['intensity'] ?? 0,
                                      date:
                                          (data['date'] as Timestamp?)
                                              ?.toDate() ??
                                          DateTime.now(),
                                      place: data['place'] ?? 'No Place',
                                      marker: Marker(
                                        point: LatLng(
                                          data['latitude'] as double,
                                          data['longitude'] as double,
                                        ),
                                        width: 30,
                                        height: 30,
                                        child: getIcon(data['type']),
                                      ),
                                    );
                                  }).toList();
                                  //myMarkerList.update();

                                  return PopupMarkerLayer(
                                    options: PopupMarkerLayerOptions(
                                      popupController: _popupController,
                                      markers: list
                                          .map((m) => m.marker)
                                          .toList(),
                                      popupDisplayOptions: PopupDisplayOptions(
                                        builder: (context, marker) {
                                          // Trova il marker corrimarkerDataspondente nella lista
                                          int index = list.indexWhere(
                                            (m) => m.marker == marker,
                                          );
                                          if (index == -1) {
                                            return Card(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  'Marker not found',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }
                                          var markerData = list.firstWhere(
                                            (m) => m.marker == marker,
                                          );
                                          return Card(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  child: Text(
                                                    "ID: " +
                                                        markerData.id +
                                                        "\n"
                                                            "Type: ${markerData.type}\n"
                                                            "Description: ${markerData.description}\n"
                                                            "Intensity: ${markerData.intensity}\n"
                                                            "Date: ${markerData.date}\n"
                                                            "Place: ${markerData.place}",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                _buildElevatedButton(
                                                  markerData.id,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // 2. Livello dei marker
                              PopupMarkerLayer(
                                options: PopupMarkerLayerOptions(
                                  popupController: _popupController2,
                                  markers: [localMarker],
                                  popupDisplayOptions: PopupDisplayOptions(
                                    builder: (context, marker) {
                                      return Card(
                                        color: Color.fromRGBO(255, 255, 255, 1),

                                        child: Padding(
                                          padding: const EdgeInsets.all(8),

                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'POSIZIONE NUOVA SEGNALAZIONE',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                'Point: ${marker.point.latitude}, ${marker.point.longitude}\n'
                                                'Place: ${placeName}',
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  widget.changeState(
                                                    1,
                                                    marker.point,
                                                    placeName,
                                                  );
                                                },
                                                child: const Text('INVIA'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color.fromRGBO(
                                                        90,
                                                        2,
                                                        18,
                                                        1,
                                                      ),
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1), // spazio a destra
              ],
            ),
          ),

          // --- ISTRUZIONI ---
          Expanded(
  flex: 1,
  child: Row(
    children: [
      const Spacer(flex: 1),
      Expanded(
        flex: 6,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1.2, color: Colors.black26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Istruzioni per l’uso della mappa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Usa i gesti per navigare nella mappa.\n'
                  '2. Clicca sui marker per ulteriori informazioni.\n'
                  '3. Puoi zoomare in e out con i pinchi o i pulsanti di zoom.\n'
                  '4. Per tornare alla home, usa il pulsante di navigazione.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
      const Spacer(flex: 1),
    ],
  ),
)

        ],
      ),
    );
  }

  SvgPicture getIcon(String type) {
    final hazardIcons = {
      "ONDE DI CALORE ESTREME": SvgPicture.asset(
        "assets/icons/fever.svg",
        width: 20,
        height: 20,
      ),
      "PIOGGE INTENSE E ALLUVIONI FLASH": SvgPicture.asset(
        "assets/icons/flood.svg",
        width: 20,
        height: 20,
      ),
      "INCENDI BOSCHIVI PERIURBANI": SvgPicture.asset(
        "assets/icons/wildfire.svg",
        width: 20,
        height: 20,
      ),
      "FRANE URBANE E COLATE DI DETRITI": SvgPicture.asset(
        "assets/icons/landslide.svg",
        width: 20,
        height: 20,
      ),
      "TERREMOTI": SvgPicture.asset(
        "assets/icons/earthquake.svg",
        width: 20,
        height: 20,
      ),
      "ESPLISIONI INDUSTRIALI O CHIMICHE": SvgPicture.asset(
        "assets/icons/explosion.svg",
        width: 20,
        height: 20,
      ),
      "INCIDENTI FERROVIARI": SvgPicture.asset(
        "assets/icons/train.svg",
        width: 20,
        height: 20,
      ),
      "INCIDENTI STRADALI": SvgPicture.asset(
        "assets/icons/fender-bender.svg",
        width: 20,
        height: 20,
      ),
      "INCIDENTI AEREI": SvgPicture.asset(
        "assets/icons/crash.svg",
        width: 20,
        height: 20,
      ),
      "INCIDENTI MARITTIMI": SvgPicture.asset(
        "assets/icons/boat.svg",
        width: 20,
        height: 20,
      ),
      "INCIDENTI NUCLEARI": SvgPicture.asset(
        "assets/icons/explosion.svg",
        width: 20,
        height: 20,
      ),
      "ATTACCHI TERRORISTICI": SvgPicture.asset(
        "assets/icons/terrorist.svg",
        width: 20,
        height: 20,
      ),
    };

    return hazardIcons[type] ??
        SvgPicture.asset("assets/icons/file.svg", width: 20, height: 20);
  }

  Future<String> getPlaceName(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'my_app (your_email@example.com)',
        // Nominatim requires a valid User-Agent
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String via = data['address']['road'] ?? 'N/D';
      String numero = data['address']['house_number'] ?? 'N/D';
      String comune =
          data['address']['city'] ?? data['address']['town'] ?? 'N/D';
      return '$via $numero, $comune';
    } else {
      return 'Unknown location';
    }
  }
}
