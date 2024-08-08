import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<void> fetchAndParseRssFeed() async {
  final url = 'https://www.coindesk.com/feed/'; // Replace with your RSS feed URL
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      for (var item in items) {
        final title = item.findElements('title').single.text;
        final link = item.findElements('link').single.text;
        print('Title: $title');
        print('Link: $link');
      }
    } else {
      throw Exception('Failed to load RSS feed');
    }
  } catch (error) {
    print('Error fetching RSS feed: $error');
  }
}
