import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureConverter {
  double FtoC(double F) => (F - 32) * 5 / 9;

  double CtoF(double C) => (C * 9 / 5) + 32;

  static var conversionData, densityData, densityLocal;

  static const String _KEY_CUST_ING_LIST = "custings";

  // Fetch content from the json file
  static Future<void> _readJson() async {
    final String response = await rootBundle.loadString('lib/data/conversions.json');
    conversionData = await json.decode(response);
    final String response2 = await rootBundle.loadString('lib/data/densities.json');
    densityData = await json.decode(response2);
  }

  // Fetch content from shared prefs
  static Future<void> _readSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? customisedIngredients = prefs.getStringList(_KEY_CUST_ING_LIST);
    densityLocal = {};
    if (customisedIngredients != null) {
      for (String ingredient in customisedIngredients) {
        densityLocal[ingredient] = prefs.getDouble(ingredient);
      }
    }
  }

  static void setIngredient(String ingredient, double? value) {
    densityLocal[ingredient] = value;
    _updateSharedPref();
  }

  static void reset() {
    densityLocal = {};
    _updateSharedPref();
  }

  static Future<void> _updateSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_KEY_CUST_ING_LIST, densityLocal.keys.toList());
    for (String ingredient in densityLocal.keys) {
      await prefs.setString(ingredient, densityLocal[ingredient]);
    }
  }

  static void init() {
    _readJson();
    _readSharedPref();
  }

  static double? convertUnits(String from, String to, double amount) {
    if (from == to) return amount;
    return conversionData[from + "_to_" + to] * amount;
  }

  static List<String>? substances() {
    return densityData.keys.toList();
  }

  static List<String>? originalSubstances() {
    return densityData.keys.toList();
  }

  static double? convertSubstance(String substance, String from, String to, double amount) {
    if (["g", "kg", "lb", "oz"].contains(from)) {
      return convertUnits(from, "g", amount)! *
          1 /
          densityData[substance] *
          convertUnits("cup", to, 1)!;
    } else {
      return convertUnits(from, "cup", amount)! *
          densityData[substance] *
          convertUnits("g", to, 1)!;
    }
  }
}
