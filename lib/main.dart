// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 // const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int temperature = 10 ;
  String location = "London";
  int woeid = 44418;
  String weather = "clear";
  String abb = "c";
  String api_error_response = "Welcome";
  String latt_long='51.506321,-0.12714';

  var search_api_url =
  "https://www.metaweather.com/api/location/search/?query=";
  var location_api_url = "https://www.metaweather.com/api/location/";

  @override
  void initState() {
  super.initState();
  fetchLocation();
  }

  Future<void> fetchSearch(String input) async {
  try {
  var search_results = await http.get(search_api_url + input);
  var result = jsonDecode(search_results.body)[0];
  setState(() {
  location = result["title"];
  woeid = result["woeid"];
  latt_long = result["latt_long"];
  api_error_response = 'API response: OK. Data fetched from metaweather.com/api/';
  });
  } catch (error) {
  setState(() {
  api_error_response = 'Sorry! We do not have the data to that city.';
  });
  }
  }

  Future<void> fetchLocation() async {
  var location_result = await http.get(location_api_url + woeid.toString());
  var result = json.decode(location_result.body);
  var consolidated_weather = result["consolidated_weather"];
  var data = consolidated_weather[0];
  setState(() {
  temperature = data["the_temp"].round();
  weather = data["weather_state_name"]
      .toString()
      .replaceAll(' ', '')
      .toLowerCase();
  abb = data["weather_state_abbr"];
  });
  }

  Future<void> onTextFieldSubmitted(String input) async {
  await fetchSearch(input);
  await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoMono'),
      home: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    'https://davee.co.ke/android-repo/weather_app/'+ weather +'.png'),
                fit: BoxFit.cover),
          ),
          child: woeid == null
              ? Center(child: CircularProgressIndicator())
              // ignore: dead_code
              :  Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Center(
                      child: Image.network(
                        'https://www.metaweather.com/static/img/weather/png/' +
                            abb +
                            '.png',
                        width: 100,
                      ),
                    ),
                    Center(
                      child: Text(
                        temperature.toString() + '°C',
                        style:
                        const TextStyle(fontSize: 60, color: Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        location,
                        style:
                        const TextStyle(fontSize: 50, color: Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        latt_long,
                        style:
                        const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        weather,
                        style:
                        const  TextStyle(fontSize: 19, color: Colors.white),
                      ),
                    ),

                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 340,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search another city',
                          hintStyle: TextStyle(
                              fontSize: 19, color: Colors.white),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        api_error_response,
                        style: TextStyle(
                          color: Colors.limeAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
