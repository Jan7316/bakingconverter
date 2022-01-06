import 'package:bakingconverter/util/Converters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TempConverterPage extends StatefulWidget {
  const TempConverterPage({Key? key}) : super(key: key);

  @override
  State<TempConverterPage> createState() => _TempConverterPageState();
}

class _TempConverterPageState extends State<TempConverterPage> {
  String dropdownValue = "C";
  double? tempVal;

  @override
  Widget build(BuildContext context) {
    String temp = "";
    if (tempVal == null) {
      temp = "°" + (dropdownValue == "C" ? "F" : "C");
    } else {
      double tempValConv = 0;
      if (dropdownValue == "C") {
        tempValConv = TemperatureConverter().CtoF(tempVal!);
      } else {
        tempValConv = TemperatureConverter().FtoC(tempVal!);
      }
      temp = tempValConv.toStringAsFixed(0) +
          " °" +
          (dropdownValue == "C" ? "F" : "C");
    }

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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Temperature',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      LengthLimitingTextInputFormatter(6)
                    ],
                    onChanged: (String text) {
                      setState(() {
                        tempVal = double.tryParse(text);
                      });
                    },
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton(
                  value: dropdownValue,
                  items: [
                    DropdownMenuItem<String>(value: "C", child: Text("°C")),
                    DropdownMenuItem<String>(value: "F", child: Text("°F")),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )
              ],
            ),
            SizedBox(height: 15,),
            Text("is the same as", style: Theme
                .of(context)
                .textTheme
                .bodyText1,),
            SizedBox(height: 15,),
            Text(temp, style: Theme
                .of(context)
                .textTheme
                .bodyText2,)
          ],
        ),
      ),
    );
  }
}
