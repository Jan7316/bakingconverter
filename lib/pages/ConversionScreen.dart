import 'package:bakingconverter/util/Converters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({Key? key}) : super(key: key);

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> with AutomaticKeepAliveClientMixin<UnitConverterPage> {
  String from = "cup";
  String to = "ml";
  double? rawValue;

  List<String> weights = ["g", "kg", "lb", "oz"];
  List<String> volumes = [
    "ml",
    "l",
    "cup",
    "tsp",
    "tbsp",
    "pint",
    "quart",
    "floz"
  ];
  List<String> volumesStrings = [
    "ml",
    "l",
    "US cup",
    "US tsp",
    "US tbsp",
    "US pint",
    "US quart",
    "fl. oz."
  ];

  List<DropdownMenuItem<String>>? weightItems;
  List<DropdownMenuItem<String>>? volumeItems;
  List<DropdownMenuItem<String>>? combinedItems;

  _UnitConverterPageState() {
    weightItems = List.generate(
        4,
        (index) => DropdownMenuItem<String>(
            value: weights[index], child: Text(weights[index])));
    volumeItems = List.generate(
        8,
        (index) => DropdownMenuItem<String>(
            value: volumes[index], child: Text(volumesStrings[index])));
    combinedItems = weightItems! + volumeItems!;
  }

  @override
  Widget build(BuildContext context) {
    String result = "";
    if (weights.contains(from) && (!weights.contains(to) || from == to)) {
      List tempList = List.from(weights);
      tempList.remove(from);
      to = tempList[0];
    } else if (!weights.contains(from) && (weights.contains(to) || from == to)) {
      List tempList = List.from(volumes);
      tempList.remove(from);
      to = tempList[0];
    }
    if (rawValue != null) {
      result = TemperatureConverter.convertUnits(from, to, rawValue!)!.toStringAsPrecision(5).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"),"");
    }
    List<DropdownMenuItem<String>> toItems = weights.contains(to) ? List.of(weightItems!) : List.of(volumeItems!);
    toItems.removeAt(weights.contains(to) ? weights.indexOf(from) : volumes.indexOf(from));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Amount',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      LengthLimitingTextInputFormatter(6)
                    ],
                    onChanged: (String text) {
                      setState(() {
                        rawValue = double.tryParse(text);
                      });
                    },
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton(
                  value: from,
                  items: combinedItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      from = newValue!;
                    });
                  },
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "is the same as",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    result,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton(
                  value: to,
                  items: toItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      to = newValue!;
                    });
                  },
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
