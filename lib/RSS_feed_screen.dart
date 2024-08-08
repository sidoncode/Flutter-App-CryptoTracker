import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class RssFeedScreen extends StatefulWidget {
  @override
  _RssFeedScreenState createState() => _RssFeedScreenState();
}

class _RssFeedScreenState extends State<RssFeedScreen> {
  List<Map<String, String>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRssFeed();
  }

  Future<void> _fetchRssFeed() async {
    final url = 'https://www.coindesk.com/feed/'; // Replace with your RSS feed URL
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        setState(() {
          _articles = items.map((item) {
            final title = item.findElements('title').single.text;
            final link = item.findElements('link').single.text;
            return {'title': title, 'link': link};
          }).toList();
        });
      } else {
        throw Exception('Failed to load RSS feed');
      }
    } catch (error) {
      print('Error fetching RSS feed: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto News RSS Feed'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _articles.isEmpty
              ? Center(child: Text('No articles available'))
              : ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return ListTile(
                      title: Text(article['title'] ?? 'No title'),
                      onTap: () {
                        final url = article['link'];
                        if (url != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(url: url),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class WebViewScreen extends StatelessWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
