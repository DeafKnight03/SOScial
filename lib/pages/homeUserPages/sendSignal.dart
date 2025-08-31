import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:my_app/main.dart';

class Sendsignal extends StatefulWidget {
  final void Function(int, LatLng?, String?) changeState;
  final LatLng? location;
  final String? placeName;
  const Sendsignal({
    super.key,
    required this.changeState,
    required this.location,
    required this.placeName,
  });

  @override
  _SendsignalState createState() => _SendsignalState();
}

class _SendsignalState extends State<Sendsignal> {
  // Controllers for text fields
  bool disabled = false;
  final picker = ImagePicker();
  List<XFile> imgList = [];
  final descriptionController = TextEditingController();

  // Dropdown values
  String dropdown1 = 'INCIDENTI STRADALI';
  String dropdown2 = '1';

  // Date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _doStuff() async {
    if (descriptionController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      messengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Per favore, compila tutti i campi obbligatori."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (DateTime.fromMillisecondsSinceEpoch(selectedDate!.millisecondsSinceEpoch + selectedTime!.hour * 3600000 + selectedTime!.minute * 60000).isAfter(DateTime.now())) {
      messengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text(
            "La data e l'ora selezionate non possono essere oltre quelle odierne.",
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      disabled = true;
    });
    List<String> uploadedUrls = [];
    messengerKey.currentState!.showSnackBar(
      const SnackBar(
        content: Text("Invio della segnalazione in corso..."),
        //duration: Duration(seconds: 10),
      ),
    );
    try {
      if (kIsWeb) {
        // Handle web-specific logic
        for (XFile file in imgList) {
          // Do something with each file
          final bytes = await file.readAsBytes();
          var fileName = DateTime.now().millisecondsSinceEpoch.toString();
          var storageRef = FirebaseStorage.instance.ref().child(
            'signals/$fileName',
          );
          await storageRef.putData(bytes);
          final url = await storageRef.getDownloadURL();
          uploadedUrls.add(url);
        }
      } else {
        for (var file in imgList) {
          // Do something with each file
          var fileName = DateTime.now().millisecondsSinceEpoch.toString();
          var storageRef = FirebaseStorage.instance.ref().child(
            'signals/$fileName',
          );
          await storageRef.putFile(File(file.path));
          final url = await storageRef.getDownloadURL();
          uploadedUrls.add(url);
        }
      }
      // Upload images to Firebase Storage

      await FirebaseFirestore.instance.collection('signals').add({
        'description': descriptionController.text,
        'category': dropdown1,
        'intensity': int.parse(dropdown2),
        'date': DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
          0,
        ),
        'latitude': widget.location?.latitude,
        'longitude': widget.location?.longitude,
        'placeName': widget.placeName,
        'imageUrls': uploadedUrls,
      });
      messengerKey.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Segnalazione inviata con successo!"),
            duration: Duration(seconds: 2), // scompare dopo 2 secondi
          ),
        );
      Future.delayed(const Duration(seconds: 3), () {
        widget.changeState(0, null, null);
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Errore durante l'invio della segnalazione: ${e.message}",
          ),
        ),
      );
    }
  }

  _multiImagePicker() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      for (var file in pickedFiles) {
        imgList.add(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller1 = TextEditingController(text: (widget.placeName ?? ''));
    final controller2 = TextEditingController(
      text:
          (widget.location?.latitude.toString() ?? '') +
          ', ' +
          (widget.location?.longitude.toString() ?? ''),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('MODULO'),backgroundColor:   Color.fromRGBO(56, 0, 10, 1.0),foregroundColor: Colors.white,),
      backgroundColor: Color.fromARGB(255, 255, 208, 176),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 253, 197, 160),
              border: Border.all(
                color:  Color.fromRGBO(56, 0, 10, 1.0),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Prima riga: 2 campi
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller1,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Campo 1'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller2,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Campo 2'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Seconda riga: 2 select (dropdown)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: dropdown1,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ONDE DI CALORE ESTREME',
                            child: Text('Onde di calore estreme'),
                          ),
                          DropdownMenuItem(
                            value: 'PIOGGE INTENSE E ALLUVIONI FLASH',
                            child: Text('Piogge intense e alluvioni flash'),
                          ),
                          DropdownMenuItem(
                            value: 'INCENDI BOSCHIVI PERIURBANI',
                            child: Text('Incendi boschivi periurbani'),
                          ),
                          DropdownMenuItem(
                            value: 'FRANE URBANE E COLATE DI DETRITI',
                            child: Text('Frane urbane e colate di detriti'),
                          ),
                          DropdownMenuItem(
                            value: 'TERREMOTI',
                            child: Text('Terremoti'),
                          ),
                          DropdownMenuItem(
                            value: 'ESPLISIONI INDUSTRIALI O CHIMICHE',
                            child: Text(
                              'Esplosioni industriali o chimiche (man-made)',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'INCIDENTI FERROVIARI',
                            child: Text('Incidenti ferroviari'),
                          ),
                          DropdownMenuItem(
                            value: 'INCIDENTI STRADALI',
                            child: Text('Incidenti stradali'),
                          ),
                          DropdownMenuItem(
                            value: 'INCIDENTI AEREI',
                            child: Text('Incidenti aerei'),
                          ),
                          DropdownMenuItem(
                            value: 'INCIDENTI MARITTIMI',
                            child: Text('Incidenti marittimi'),
                          ),
                          DropdownMenuItem(
                            value: 'INCIDENTI NUCLEARI',
                            child: Text('Incidenti nucleari'),
                          ),
                          DropdownMenuItem(
                            value: 'ATTACCHI TERRORISTICI',
                            child: Text('Attacchi terroristici'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            dropdown1 = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: dropdown2,
                        decoration: const InputDecoration(
                          labelText: 'Intensità',
                        ),
                        items: const [
                          DropdownMenuItem(value: '1', child: Text('1')),
                          DropdownMenuItem(value: '2', child: Text('2')),
                          DropdownMenuItem(value: '3', child: Text('3')),
                          DropdownMenuItem(value: '4', child: Text('4')),
                          DropdownMenuItem(value: '5', child: Text('5')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            dropdown2 = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Terza riga: data e ora
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Data'),
                          child: Text(
                            selectedDate == null
                                ? 'Seleziona una data'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Ora'),
                          child: Text(
                            selectedTime == null
                                ? 'Seleziona un\'ora'
                                : selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quarta riga: textarea multiline (5 righe)
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _multiImagePicker();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:  Color.fromRGBO(56, 0, 10, 1.0),
                    foregroundColor: Colors.white
                  ),
                  child: const Text('Allega immagini'),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: disabled
                      ? null
                      : () {
                          // Gestione invio

                          print('Campo1: ${controller1.text}');
                          print('Campo2: ${controller2.text}');
                          print('Dropdown1: $dropdown1');
                          print('Dropdown2: $dropdown2');
                          print('Data: $selectedDate');
                          print('Ora: $selectedTime');
                          print('Descrizione: ${descriptionController.text}');

                          _doStuff();
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color.fromRGBO(56, 0, 10, 1.0),
                    foregroundColor: Colors.white
                  ),
                  child: const Text('Invia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
