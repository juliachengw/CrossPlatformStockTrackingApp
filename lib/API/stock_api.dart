import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import '../page/search.dart';
import '../main.dart';
import '../model/stock.dart';

//stock listing and stock result
class StockApi {
  static const apiKey = 'c9isf1qad3iblk5agj2g';

  static Future<List<String>> searchStocks({required String query}) async {
    final url =
        Uri.parse("https://finnhub.io/api/v1/search?q=$query&token=$apiKey");

    final response = await http.get(url);
    final body = json.decode(response.body);

    return body["result"].map<String>((stock) {
      final symbol = stock["symbol"];
      final description = stock["description"];
      return "$symbol | $description";
    }).toList();
  }

  /// get stock details to render stock watch result
  static Future<Stock> getStock({@required String? symbol}) async {
    final profileURL = Uri.parse(
        "https://finnhub.io/api/v1/stock/profile2?symbol=$symbol&token=$apiKey");
    final priceURL = Uri.parse(
        "https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey");

    final profileResponse = await http.get(profileURL);
    final priceResponse = await http.get(priceURL);
    final profileBody = json.decode(profileResponse.body);
    final priceBody = json.decode(priceResponse.body);
    // print("stock price JSON: " + priceBody.toString());

    return _populateStockInfo(profileBody, priceBody);
  }

  // helper function for getStock method to populate the stock information object
  static Stock _populateStockInfo(profileJson, priceJson) {
    return Stock(
        ticker: profileJson["ticker"],
        companyName: profileJson["name"],
        currPrice: priceJson["c"].toDouble(),
        priceChange: priceJson["d"].toDouble(),
        openPrice: priceJson["o"].toDouble(),
        prevPrice: priceJson["pc"].toDouble(),
        lowPrice: priceJson["l"].toDouble(),
        highPrice: priceJson["h"].toDouble(),
        IPODate: profileJson["ipo"],
        industry: profileJson["finnhubIndustry"],
        website: profileJson["weburl"],
        exchange: profileJson["exchange"],
        marketCap: profileJson["marketCapitalization"].round());
  }
}
