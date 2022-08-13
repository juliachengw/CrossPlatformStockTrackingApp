import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import '../model/shared_perf.dart';
import "../model/stock.dart";
import 'package:url_launcher/url_launcher.dart';
import "../API/stock_api.dart";

class StockResultPage extends StatefulWidget {
  SharedPref sharedPref = SharedPref();
  String query;
  //favoriteStockList example: ["AMZN | Amazon Inc,Amazon Inc",...] ,the comma being the separator inside the string.
  // This is for displaying the stock fav list with ticker and company name
  late List<String> favoriteStockList;
  late bool liked = false;
  late Future<Stock>? stock;
  late String ticker;
  late String companyName;
  Function callback;

  StockResultPage(this.query, this.callback, {Key? key}) : super(key: key) {
    try {
      Iterable i = sharedPref.read();
      favoriteStockList = List<String>.from(i.map((jsonString) => jsonString));
    } catch (excepetion) {
      favoriteStockList = [];
    }

    for (String stockStrings in favoriteStockList) {
      if (stockStrings.split(",")[0] == query) {
        liked = true;
      }
    }
    ticker = query.split(" ")[0];
    stock = StockApi.getStock(symbol: ticker);
  }

  @override
  State<StockResultPage> createState() => _StockResultPageState();
}

class _StockResultPageState extends State<StockResultPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
          backgroundColor: Colors.grey.shade900,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(widget.liked ? Icons.star : Icons.star_border),
              onPressed: () {
                String snackBarText;
                if (widget.liked) {
                  snackBarText = "${widget.ticker} was removed from watchlist";
                  // remove stock from the favorite list
                  for (int i = 0; i < widget.favoriteStockList.length; i++) {
                    if (widget.favoriteStockList[i].split(",")[0] ==
                        widget.query) {
                      widget.favoriteStockList.removeAt(i);
                      break;
                    }
                  }
                } else {
                  snackBarText = "${widget.ticker} was added to watchlist";

                  // add stock into the favorite list
                  widget.favoriteStockList
                      .add("${widget.query},${widget.companyName}");
                }

                // print("fav list:" + widget.favoriteStockList.toString());
                widget.liked = !widget.liked;
                widget.sharedPref.save(widget.favoriteStockList);

                // delete old message and show new message
                ScaffoldMessenger.of(context)
                    .removeCurrentSnackBar(reason: SnackBarClosedReason.action);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      snackBarText,
                      style: TextStyle(color: Colors.grey.shade900),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
                // refresh the page to re-render the favoride button
                setState(() {});
                widget.callback();
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.black,
          child: FutureBuilder<Stock>(
            future: widget
                .stock, // get the symbol in the concatenated string e.g. GOOG | ALP...
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.hasError) {
                    return Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: const Text(
                        'Failed to fetch stock data',
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    );
                  } else {
                    widget.companyName = snapshot.data!.companyName;

                    return buildResultSuccess(snapshot.data!);
                  }
              }
            },
          ),
        ),
      );

// helper widget for displaying the stock details after succesfully fetching JSON
  Widget buildResultSuccess(Stock stock) => Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            stockTitle(stock),
            stockCurrPrice(stock),
            stockStats(stock),
            stockAbout(stock),
          ],
        ),
      );

// helper widget for displaying stock details - stock title
  Widget stockTitle(Stock stock) => Container(
        padding: const EdgeInsets.only(top: 20, left: 12),
        child: Row(
          children: [
            Text(
              stock.ticker,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 14),
                child: Text(
                  stock.companyName,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white54,
                  ),
                ),
              ),
            )
          ],
        ),
      );

// helper widget for displaying stock details - stock current price
  Widget stockCurrPrice(Stock stock) => Container(
        padding: const EdgeInsets.only(left: 12, top: 20, bottom: 10),
        child: Row(
          children: [
            Text(
              stock.currPrice.toString(),
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 14),
              child: priceChangeText(stock.priceChange),
            ),
          ],
        ),
      );

// helper widget for price change text
  Widget priceChangeText(priceChange) {
    Color color;
    String sign;
    if (priceChange >= 0) {
      color = Colors.green;
      sign = "+";
    } else {
      color = Colors.red;
      sign = "";
    }

    TextStyle style = TextStyle(
      fontSize: 25,
      color: color,
    );

    Text text = Text(
      sign + priceChange.toString(),
      style: style,
    );
    return text;
  }

// helper widget for displaying stock details - stock price stats
  Widget stockStats(Stock stock) => Container(
        padding: const EdgeInsets.all(12),
        child: (Column(
          children: [
            Row(
              children: const [
                Text(
                  "Stats",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // open price and high price row
            statsRow("Open", "High", stock.openPrice, stock.highPrice),
            // low price and prev price row
            statsRow("Low", "Prev", stock.lowPrice, stock.prevPrice),
          ],
        )),
      );

// helper container to format stock stat row
  Container statsRow(label1, label2, price1, price2) => Container(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            //open price
            SizedBox(
              width: 210,
              child: Center(
                child: Row(children: [
                  SizedBox(
                    width: 55,
                    child: Center(
                      child: Text(
                        label1,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        price1.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            SizedBox(
              // high price
              width: 180,
              child: Row(children: [
                SizedBox(
                  width: 55,
                  child: Text(
                    label2,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      price2.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      );

// helper widget for displaying stock details - stock About info
  Widget stockAbout(Stock stock) => Container(
        width: 400,
        padding: const EdgeInsets.only(left: 12, top: 10),
        child: Column(
          children: [
            Row(
              children: const [
                Text(
                  "About",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            aboutRow("Start date", stock.IPODate),
            aboutRow("Industry", stock.industry),
            aboutURLRow("Website", stock.website),
            aboutRow("Exchange", stock.exchange),
            aboutRow("Market Cap", stock.marketCap.toString()),
          ],
        ),
      );

// helper container to format row in About section
  Container aboutRow(label, info) => Container(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Text(
                info,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      );

  Container aboutURLRow(label, info) {
    final url = Uri.parse(info);
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          //open price
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                child: RichText(
                  text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                      text: info,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
