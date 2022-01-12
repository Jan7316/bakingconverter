import 'package:bakingconverter/util/Converters.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CupConverterPage extends StatefulWidget {
  const CupConverterPage({Key? key}) : super(key: key);

  @override
  State<CupConverterPage> createState() => _CupConverterPageState();
}

class _CupConverterPageState extends State<CupConverterPage> with AutomaticKeepAliveClientMixin<CupConverterPage> {
  String from = "cup";
  String to = "g";
  double? rawValue;
  String? substance;

  String editorFrom = "cup";
  String editorTo = "g";

  List<String> weights = ["g", "kg", "lb", "oz"];
  List<String> volumes = ["ml", "l", "cup", "tsp", "tbsp", "pint", "quart", "floz"];
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

  _CupConverterPageState() {
    weightItems = List.generate(
        4, (index) => DropdownMenuItem<String>(value: weights[index], child: Text(weights[index])));
    volumeItems = List.generate(
        8,
        (index) =>
            DropdownMenuItem<String>(value: volumes[index], child: Text(volumesStrings[index])));
    combinedItems = weightItems! + volumeItems!;
  }

  @override
  Widget build(BuildContext context) {
    String result = "";
    if (volumes.contains(from) && volumes.contains(to)) {
      List tempList = List.from(weights);
      to = tempList[0];
    } else if (weights.contains(from) && weights.contains(to)) {
      List tempList = List.from(volumes);
      to = tempList[0];
    }
    if (rawValue != null) {
      if (substance == null) {
        result = "";
      } else {
        result = TemperatureConverter.convertSubstance(substance!, from, to, rawValue!)
                ?.toStringAsPrecision(5)
                .replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "") ??
            "";
      }
    }
    List<DropdownMenuItem<String>> toItems =
        weights.contains(from) ? List.of(volumeItems!) : List.of(weightItems!);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatefulBuilder(builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
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
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(
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
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  )
                ],
              );
            }),
            const SizedBox(
              height: 15,
            ),
            Text(
              "of",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(
              height: 15,
            ),
            DropdownSearch<String>(
                mode: Mode.MENU,
                showSearchBox: true,
                items: TemperatureConverter.substances(),
                label: "Ingredient",
                emptyBuilder: (context, searchEntry) => Center(child: Text('No ingredient found')),
                onChanged: (selected) => {
                      setState(() {
                        substance = selected;
                      })
                    },
                selectedItem: substance),
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
            const SizedBox(
              height: 25,
            ),
            CupertinoButton(
              child: Text("Edit ingredient",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)),
              onPressed: substance == null
                  ? null
                  : () => {_showDialog(context, editing: substance, from: from, to: to)},
              color: Colors.blue,
            ),
            const SizedBox(
              height: 15,
            ),
            CupertinoButton(
                child: Text("New ingredient",
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)),
                onPressed: () {
                  _showDialog(context);
                },
                color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, {String? editing, String? from, String? to}) {
    double? density =
        editing == null ? null : TemperatureConverter.convertSubstance(editing, "cup", "g", 1);
    TextEditingController textEditingController = TextEditingController()..text = density == null ? "" : density.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setOuterState) => Center(
            child: Column(children: [
          const Spacer(
            flex: 1,
          ),
          Dialog(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      (editing == null) ? "Add ingredient" : "Edit ingredient",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    (editing == null)
                        ? const TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Ingredient name',
                            ),
                            style: TextStyle(fontSize: 20),
                          )
                        : Text(
                            editing,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(textStyle: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w200)),
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    (editing == null)
                        ? StatefulBuilder(
                            builder: (context, setState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  DropdownButton(
                                    value: editorTo,
                                    items: weightItems,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        editorTo = newValue ?? "g";
                                      });
                                    },
                                    style: const TextStyle(fontSize: 20, color: Colors.black),
                                  ),
                                  Text(
                                    "per",
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                  DropdownButton(
                                    value: editorFrom,
                                    items: volumeItems,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        editorFrom = newValue ?? "cup";
                                      });
                                    },
                                    style: TextStyle(fontSize: 20, color: Colors.black),
                                  )
                                ],
                              );
                            },
                          )
                        : Text(
                            "$to per $from",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Value',
                      ),
                      style: TextStyle(fontSize: 20),
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        LengthLimitingTextInputFormatter(6)
                      ],
                      onChanged: (newText) {
                        setOuterState(() {density = double.tryParse(newText);});
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                            child: Text(
                              editing == null ? "Cancel" : "Delete",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (editing != null &&
                                          TemperatureConverter.originalSubstances()!
                                              .contains(editing))
                                      ? Colors.grey
                                      : Colors.blue),
                            ),
                            onPressed: (editing != null &&
                                    TemperatureConverter.originalSubstances()!.contains(editing))
                                ? null
                                : () => {Navigator.pop(context)}),
                        MaterialButton(
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (density == null ? Colors.grey : Colors.blue)),
                            ),
                            onPressed: density == null ? null : () => {Navigator.pop(context)}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(
            flex: 1,
          )
        ])),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
