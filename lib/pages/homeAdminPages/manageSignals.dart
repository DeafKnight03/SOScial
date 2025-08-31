import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/customClasses/SimpleImageScroller.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageSignals extends StatefulWidget {
  const ManageSignals({super.key});

  @override
  State<ManageSignals> createState() => _ManageSignalsState();
}

class _ManageSignalsState extends State<ManageSignals> {
  /*FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('signals/1756148853439');*/

  String currentIndex = "-1";
  void approveSignal() {
    // Implement approval logic
    if (currentIndex != "-1") {
      String type = "0";
      int intensity = 0;
      String placeName = "0";
      DateTime date = DateTime.now();
      String description = "0";
      double latitude = 0;
      double longitude = 0;

      FirebaseFirestore.instance
          .collection('signals')
          .doc(currentIndex)
          .get()
          .then((doc) {
            if (doc.exists) {
              print(currentIndex);
              // Document exists, you can access its data
              var data = doc.data();
              type = data?['category'] ?? "0";
              intensity = data?['intensity'] ?? 0;
              placeName = data?['placeName'] ?? "0";
              date = (data?['date'] as Timestamp).toDate();
              description = data?['description'] ?? "0";
              latitude = data?['latitude'] ?? 0;
              longitude = data?['longitude'] ?? 0;
              FirebaseFirestore.instance
                  .collection('events')
                  .add({
                    'type': type,
                    'intensity': intensity,
                    'place': placeName,
                    'date': date,
                    'description': description,
                    'latitude': latitude,
                    'longitude': longitude,
                  })
                  .then(
                    (value) => FirebaseFirestore.instance
                        .collection('removals')
                        .doc(value.id)
                        .set({'nRemovals': []}),
                  );

              for (String url in List<String>.from(data?['imageUrls'] ?? [])) {
                Reference ref = FirebaseStorage.instance.refFromURL(url);
                ref.delete();
              }

              FirebaseStorage.instance
                  .ref()
                  .child('signals/$currentIndex')
                  .delete();
              FirebaseFirestore.instance
                  .collection('signals')
                  .doc(currentIndex)
                  .delete();
            }
          });
    }
  }

  void rejectSignal() {
    // Implement rejection logic
    if (currentIndex != "-1") {
      FirebaseFirestore.instance
          .collection('signals')
          .doc(currentIndex)
          .get()
          .then((doc) {
            if (doc.exists) {
              var data = doc.data();
              for (String url in List<String>.from(data?['imageUrls'] ?? [])) {
                Reference ref = FirebaseStorage.instance.refFromURL(url);
                ref.delete();
              }
              FirebaseStorage.instance
                  .ref()
                  .child('signals/$currentIndex')
                  .delete();
              FirebaseFirestore.instance
                  .collection('signals')
                  .doc(currentIndex)
                  .delete();
            }
          });
      FirebaseFirestore.instance
          .collection('signals')
          .doc(currentIndex)
          .delete();
      setState(() {
        currentIndex = "-1";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex == "-1") {
      return Row(
        children: [
          Column(
            
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height * 0.75,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('signals')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("Nessuna segnalazione di aggiunta disponibile"),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        const ListTile(
                          title: Text("TUTTE LE SEGNALAZIONI DI AGGIUNTA",textAlign: TextAlign.center),
                          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        ...snapshot.data!.docs.map((doc) {
                          var data = doc.data();
                          String s = "";
                          s += data['placeName'];
                          s += " - ";
                          s += data['intensity'].toString();
                        return ListTile(
                          title: Text(
                            data['category'],
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            s,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            // Handle tap
                            setState(() {
                              currentIndex = doc.id;
                            });
                          },
                        );
                      }).toList(),
                      ]
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height * 0.75,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('removals')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var newRes = snapshot.data!.docs.where((doc) {
                      var data = doc.data();
                      return List<String>.from(data['nRemovals'] ?? []).isNotEmpty;
                    });

                    if (newRes.isEmpty) {
                      return const Center(
                        child: Text("Nessuna segnalazione di rimozione disponibile"),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const ListTile(
                          title: Text("TUTTE LE SEGNALAZIONI DI RIMOZIONE",textAlign: TextAlign.center),
                          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        ...newRes.map((doc) {
                          var data = doc.data();
                          String s2 = "";
                          String s3 = "";
                          s2 = doc.id;
                          print(List<String>.from(data['nRemovals'] ?? []).length);
                          s3 = (List<String>.from(data['nRemovals'] ?? []).length).toString() + " persone chiedono la rimozione";
                        return ListTile(
                          title: Text(
                            s2,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            s3,
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            // Handle tap
                            setState(() {
                              currentIndex = "-" + doc.id;
                            });
                          },
                        );
                      }).toList(),
                      ]
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }else if (currentIndex.startsWith("-")) {
      // Details for selected removal signal
      String id = currentIndex.substring(1);
      print(id);
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              currentIndex = "-1";
            });
          });
          return const SizedBox.shrink();
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
       
        return Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Center(child: Text(data['type']))),
                    Expanded(child: Center(child: Text(data['place']))),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Center(child: Text(data['intensity'].toString())),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          (data['date'] as Timestamp).toDate().toString(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Center(child: Text(data['description']))),
                  ],
                ),
                const SizedBox(height: 32),

                

                Row(
                  children: [
                    Spacer(flex: 1),
                    
                      ElevatedButton(
                      onPressed: () {
                        // Handle removal logic
                        FirebaseFirestore.instance
                            .collection('events')
                            .doc(id)
                            .delete();
                        FirebaseFirestore.instance
                            .collection('removals')
                            .doc(id)
                            .delete();
                      },
                      child: Center(
                        child: Text(
                          "Rimuovi Evento",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                    Spacer(flex: 1),

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    }
    // Details for selected signal
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('signals')
          .doc(currentIndex)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              currentIndex = "-1";
            });
          });
          return const SizedBox.shrink();
        }
        var data = snapshot.data!.data() as Map<String, dynamic>;
        List<String> array = List<String>.from(
          snapshot.data!.get('imageUrls') ?? [],
        );
        return Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height*0.75,
            width: MediaQuery.of(context).size.width*0.75,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Center(child: Text(data['category']))),
                    Expanded(child: Center(child: Text(data['placeName']))),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Center(child: Text(data['intensity'].toString())),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          (data['date'] as Timestamp).toDate().toString(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Center(child: Text(data['description']))),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: 350,
                  height: 250,
                  child: SimpleImageScroller(imageUrls: array),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Spacer(flex: 1),
                    ElevatedButton(
                      onPressed: rejectSignal,
                      child: Center(
                        child: Text(
                          "Abbandona Segnalazione",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    Spacer(flex: 1),
                    ElevatedButton(
                      onPressed: approveSignal,
                      child: Center(
                        child: Text(
                          "Approva Segnalazione",
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
