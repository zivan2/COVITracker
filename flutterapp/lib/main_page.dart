import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;

class MainPage extends StatefulWidget {
  MainPage({Key key, this.stateName}) : super(key: key);

  final String stateName;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<List> futureStateData;

  Future<List> _fetchStateData(String stateName) async {
    final response = await http.get(
        'https://covidtracking.com/api/v1/states/' + stateName + '/daily.json');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return Album.fromJson(json.decode(response.body));
      List data = json.decode(response.body);
      // Return data as a list of Maps containing data for each day
      return data;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void _updateStateData() =>
      futureStateData = _fetchStateData(widget.stateName);

  @override
  void initState() {
    super.initState();
    _updateStateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COVID Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List>(
              future: futureStateData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Cases today: ' +
                      snapshot.data[0]['positive'].toString());
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
            FloatingActionButton(
              onPressed: _updateStateData,
              tooltip: 'Increment',
              child: new Icon(Icons.refresh),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CasesOverTimeChart extends StatelessWidget {
  final List<dynamic> data;
  // List<charts.Series> seriesList;

  CasesOverTimeChart(this.data);

  factory CasesOverTimeChart.create(List data) =>
      new CasesOverTimeChart(_getSeriesFromData(data));

  List<charts.Series<int, int>> _getSeriesFromData(List data) {
    List list = new List(data.length);
    int counter = 0;
    for (int i = 0; i <= data.length; i++) {
      list.add(new LinearCases(i, list[i]['positive']));
    }
    return [
      new charts.Series<int, int>(
        id: 'Cases',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearCases sales, _) => sales.year,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList, animate: false);
  }
}

class LinearCases {
  final int pos;
  final int cases;

  LinearCases(this.pos, this.cases);
}
