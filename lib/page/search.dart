import "package:flutter/material.dart";
import 'package:stock/page/result.dart';
import '../API/stock_api.dart';
import "../page/result.dart";

class StockSearch extends SearchDelegate<String> {
  Function callback;

  StockSearch(this.callback);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, "");
            } else {
              query = "";
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => close(context, ""),
      );

  // route to result page to display the result of stock details
  @override
  void showResults(BuildContext context) {
    close(context, "");
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (BuildContext context) => StockResultPage(query, callback)),
    );
  }

  @override
  // display search result
  Widget buildResults(BuildContext context) => Container();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: Colors.grey.shade900, // affects AppBar's background color
        iconTheme: const IconThemeData(color: Colors.white54),
      ),
      hintColor: Colors.white54,
      inputDecorationTheme:
          const InputDecorationTheme(border: InputBorder.none),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: Colors.deepPurple.shade300),
      textTheme: const TextTheme(
        //query input color and style
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
  }

  @override
  // display fetched suggestion list as we type
  Widget buildSuggestions(BuildContext context) => Container(
        color: Colors.black,
        child: FutureBuilder<List<String>>(
          future: StockApi.searchStocks(query: query),
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurple.shade300));
              default:
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return buildNoSuggestions();
                } else {
                  return buildSuggestionsSuccess(snapshot.data!);
                }
            }
          },
        ),
      );

  // helper method for buildSuggestions widget - no suggestions found
  Widget buildNoSuggestions() => const Center(
        child: Center(
          child: Text(
            'No suggestions found!',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
        ),
      );

  // helper method for buildSuggestions widget - loading suggestions
  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];

          return ListTile(
            onTap: () {
              query = suggestion;

              // 1. Close Search & Return Result
              close(context, suggestion);

              // 2. Navigate to Result Page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      StockResultPage(query, callback),
                ),
              );
            },

            // title: Text(suggestion),
            title: RichText(
              text: TextSpan(
                text: suggestion,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      );
}
