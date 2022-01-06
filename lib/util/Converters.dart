import 'dart:convert';

import 'package:flutter/services.dart';

class TemperatureConverter {
  double FtoC(double F) => (F - 32) * 5/9;
  double CtoF(double C) => (C * 9/5) + 32;

  static var conversionData, densityData;

  // Fetch content from the json file
  static Future<void> _readJson() async {
    final String response = await rootBundle.loadString('lib/data/conversions.json');
    conversionData = await json.decode(response);
    final String response2 = await rootBundle.loadString('lib/data/densities.json');
    densityData = await json.decode(response2);
  }

  static void init() {
    _readJson();
  }

  static double? convertUnits(String from, String to, double amount) {
    if(from == to) return amount;
    return conversionData[from + "_to_" + to] * amount;
  }

  static List<String>? substances() {
    return densityData.keys.toList();
  }

  static List<String>? originalSubstances() {
    return densityData.keys.toList();
  }

  static double? convertSubstance(String substance, String from, String to, double amount) {
    if(["g", "kg", "lb", "oz"].contains(from)) {
      return convertUnits(from, "g", amount)! * 1/densityData[substance] * convertUnits("cup", to, amount)!;
    } else {
      return convertUnits(from, "cup", amount)! * densityData[substance] * convertUnits("g", to, amount)!;
    }
  }
}