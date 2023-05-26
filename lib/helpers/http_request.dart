import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

Future<dynamic> sendPostData(String api, dynamic object) async {

  var client = http.Client();

  var url = Uri.parse(api);
  var _payload = json.encode(object);
  var _headers = {
    'Content-Type': 'application/json',
  };

  var response = await client.post(url, body: _payload, headers: _headers);

  if(response.statusCode == 200){
    return response.body;
  }else if(response.statusCode == 201){
    return response.body;
  }else{
    ///throw exception
  }
}