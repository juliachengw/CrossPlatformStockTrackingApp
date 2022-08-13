import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import "page/search.dart";
import "package:shared_preferences/shared_preferences.dart";
import "model/shared_perf.dart";
import "page/result.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Storage service is a service to manage all shared preferences stuff.
  // I keep the instance here for speedy access whenever it's needed.
  SharedPreferences.getInstance().then((instance) {
    preference = instance;
    // preference!.clear(); //clear fav list in case we want to start a clean slate
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      title: 'Stock Watch',
      home: const StockHomePage(),
    );
  }
}

// Home page with search bar and favorite list
class StockHomePage extends StatefulWidget {
  const StockHomePage({Key? key}) : super(key: key);

  @override
  State<StockHomePage> createState() => _StockHomePageState();
}

class _StockHomePageState extends State<StockHomePage> {
  void callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              showSearch(context: context, delegate: StockSearch(callback));
            },
          )
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SizedBox.expand(
            child: Column(children: [
          stockWatchHeader("STOCK WATCH", 25.0),
          stockWatchHeader(getTodayDate(), 25.0),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 20, left: 20, bottom: 2),
            child: const Text(
              "Favorites",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(child: favoriteListBuilder()),
        ])),
      ),
    );
  }

// helper method to load and format the stock watch list
  ListView favoriteListBuilder() {
    SharedPref sharedPref = SharedPref();
    List<String> favoriteStockList;
    try {
      Iterable i = sharedPref.read();
      favoriteStockList = List<String>.from(i.map((jsonString) => jsonString));
    } catch (excepetion) {
      favoriteStockList = [];
    }

    if (favoriteStockList.isEmpty) {
      return ListView.builder(
          itemCount: 2,
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, index) {
            if (index.isEven) {
              return const Divider(
                thickness: 1.5,
                color: Colors.white,
              );
            }
            return const ListTile(
                title: Center(
              child: Text("Empty",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )),
            ));
          });
    }
// when the fav list is not empty:
    return ListView.builder(
      itemCount: favoriteStockList.length * 2, // *2 because we add dividers
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        // show divider
        if (index.isEven) {
          return const Divider(
            thickness: 1.5,
            color: Colors.white,
          );
        }

        // show stock
        index = index ~/ 2; // to get the true index of stock in the fav list
        List<String> savedStockInfo = favoriteStockList[index].split(",");

        final query = savedStockInfo[0];
        final companyName = savedStockInfo[1];
        final ticker = query.split(" ")[0];

        return GestureDetector(
          onTap: () {
            // Navigate to Result Page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    StockResultPage(query, callback),
              ),
            );
          },
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              String ticker = favoriteStockList[index].split(",")[0];
              favoriteStockList.removeAt(index);
              sharedPref.save(favoriteStockList);
              callback();
            },
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.grey.shade800,
                    title: const Text("Delete Confirmation",
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                        "Are you sure you want to delete this item?",
                        style: TextStyle(color: Colors.white)),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            ScaffoldMessenger.of(context).removeCurrentSnackBar(
                                reason: SnackBarClosedReason.action);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "$ticker was removed from watchlist",
                                  style: TextStyle(color: Colors.grey.shade900),
                                ),
                                backgroundColor: Colors.white,
                              ),
                            );
                          },
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.white))),
                      Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            background: Container(
              color: Colors.red,
              alignment: AlignmentDirectional.centerEnd,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: ListTile(
              // title: Text(suggestion),
              title: RichText(
                text: TextSpan(
                  text: ticker + '''\n''' + companyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// helper method to format Stock watch header and date at the top right corner
  Container stockWatchHeader(label, fontSize) => Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.only(top: 10, right: 20, bottom: 0),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  // helper method to get today's day and month
  String getTodayDate() {
    DateTime now = DateTime.now();
    int monthInt = now.month;
    String month = DateFormat('MMMM').format(DateTime(0, monthInt));
    String day = DateTime.now().day.toString();
    return "$month $day";
  }
}
