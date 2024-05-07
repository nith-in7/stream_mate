import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({super.key});

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width < 450
        ? MediaQuery.of(context).size.width
        : 400;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 214, 210, 210),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close))),
          )
        ],
        leading: const UnconstrainedBox(
          child: CircleAvatar(
              radius: 20,
              backgroundColor: Color.fromARGB(255, 214, 210, 210),
              child: Icon(
                Icons.near_me,
              )),
        ),
        title: const Text("Set Location"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Color.fromARGB(255, 240, 240, 240)),
            child: const TextField(
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: "Search your location.",
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                  )),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Container(
              width: width,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Color.fromARGB(255, 240, 240, 240)),
              child: TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700),
                  onPressed: () {
                    chechPermission();
                  },
                  icon: const Icon(Icons.near_me),
                  label: const Text("Use my current location.")),
            ),
          )
        ],
      ),
    );
  }
}

//  final api = "AIzaSyBifXLCpwEBX6Mu0hIjoLMqQhVckPsaC2Q";
//   fetchAutoComplete() async {
//     final http.Response response = await http.get(
//         Uri.https(
//             "maps.googleapis.com",
//             "maps/api/place/autocomplete/json",
//             {"input": "CMR Residency", "key": api}),);
//     final body = jsonDecode(response.body);
//     print(response.body);
//   }

chechPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      Fluttertoast.showToast(msg: "Request Denied");
    }
  }
  if (permission == LocationPermission.deniedForever) {
    Fluttertoast.showToast(msg: "Request Denied, Enable it in the permissons.");
    await Geolocator.openAppSettings();
    return;
  }
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
  }
  getLocation();
}

getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    final List<Placemark> result =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    "${result[0].name}, ${result[0].locality}, ${result[0].administrativeArea}";
  } catch (e) {}
}
