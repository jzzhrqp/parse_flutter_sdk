import 'package:http/http.dart';

/// A Calculator.
class Parse {
  var serverUrl="";
  var appId="";
  var localDataStoreEnabled=false;

  static Parse _parse;

  Map<String,String> publicHeader() => {"X-Parse-Application-Id":appId,"Content-Type":"application/json"};

  Parse._in(this.serverUrl,this.appId);

  ///Initialize ParseSDK, only called once at the beginning of the program

  /// serverUrl like this: https://www.someone.com/parse
  static void create(String serverUrl,String appId){
    if(_parse==null){
      _parse=new Parse._in(serverUrl, appId);
    }
  }

  static Parse it(){
    return _parse;
  }

}
