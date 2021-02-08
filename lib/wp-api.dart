import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
final String url = "https://readingroomco.com/";
//final String api = "wp-json/wp/v2/posts?_embed";
Future<List> fetchWpPosts(String api) async{
  var response = await http.get(Uri.encodeFull(url + api),
      headers: {"Accept": "application/json;"},
      );
    var convertedJson = json.decode(utf8.decode(response.bodyBytes));
  return convertedJson;
}
