import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'coin_detail_screen.dart'; // Import the new detail screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _coins = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoins();
  }

  Future<void> _fetchCoins() async {
    final url = 'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _coins = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load coins');
      }
    } catch (error) {
      // Handle the error appropriately in a real app
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Coins'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _coins.length,
              itemBuilder: (context, index) {
                final coin = _coins[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: coin['image'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  title: Text(coin['name']),
                  subtitle: Text('\$${coin['current_price']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoinDetailScreen(
                          coinId: coin['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
