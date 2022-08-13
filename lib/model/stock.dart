// a class of stock infomation
class Stock {
  final String ticker;
  final String companyName;
  final double currPrice;
  final double priceChange;
  final double openPrice;
  final double prevPrice;
  final double lowPrice;
  final double highPrice;
  // ignore: non_constant_identifier_names
  final String IPODate;
  final String industry;
  final String website;
  final String exchange;
  final int marketCap;

  const Stock({
    required this.ticker,
    required this.companyName,
    required this.currPrice,
    required this.priceChange,
    required this.openPrice,
    required this.prevPrice,
    required this.lowPrice,
    required this.highPrice,
    required this.IPODate,
    required this.industry,
    required this.website,
    required this.exchange,
    required this.marketCap,
  });
}
