import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  Future<Map<String, dynamic>> getRates(String base) async {

    final url =
        "https://open.er-api.com/v6/latest/$base";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load rates");
    }
  }
}