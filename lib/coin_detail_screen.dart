import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';

class CoinDetailScreen extends StatefulWidget {
  final String coinId;

  CoinDetailScreen({required this.coinId});

  @override
  _CoinDetailScreenState createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  Map<String, dynamic>? _coinDetails;
  List<FlSpot> _priceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoinDetails();
    _fetchHistoricalData();
  }

  Future<void> _fetchCoinDetails() async {
    final url = 'https://api.coingecko.com/api/v3/coins/${widget.coinId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _coinDetails = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load coin details');
      }
    } catch (error) {
      print('Error fetching coin details: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHistoricalData() async {
    final url = 'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart?vs_currency=usd&days=7';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;
        setState(() {
          _priceData = prices.map((price) {
            final timestamp = DateTime.fromMillisecondsSinceEpoch(price[0]);
            final value = price[1];
            return FlSpot(timestamp.millisecondsSinceEpoch.toDouble() / 1000, value.toDouble());
          }).toList();
        });
      } else {
        throw Exception('Failed to load historical data');
      }
    } catch (error) {
      print('Error fetching historical data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coin Details'),
        elevation: 4.0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _coinDetails == null
              ? Center(child: Text('No details available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: _coinDetails!['image']['large'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          _coinDetails!['name'],
                          style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Symbol: ${_coinDetails!['symbol'].toUpperCase()}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildStatRow('Current Price:', '\$${_coinDetails!['market_data']['current_price']['usd']}'),
                      _buildStatRow('High 24h:', '\$${_coinDetails!['market_data']['high_24h']['usd']}'),
                      _buildStatRow('Low 24h:', '\$${_coinDetails!['market_data']['low_24h']['usd']}'),
                      SizedBox(height: 20),
                      Text(
                        'Description:',
                        style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _coinDetails!['description']['en'] ?? 'No description available',
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Price Graph:',
                        style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _priceData,
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            minX: _priceData.isNotEmpty ? _priceData.first.x : 0,
                            maxX: _priceData.isNotEmpty ? _priceData.last.x : 0,
                            minY: _priceData.isNotEmpty ? _priceData.map((e) => e.y).reduce((a, b) => a < b ? a : b) : 0,
                            maxY: _priceData.isNotEmpty ? _priceData.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}
