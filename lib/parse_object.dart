import 'dart:async';
import 'dart:collection';

import 'parse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class _ParseObjectBody{

}

class ParseObject{
  /*
  REST JSON Keys
  */
   final String KEY_CLASS_NAME = "className";
   final String KEY_ACL = "ACL";

   //updatedAt是以毫秒级精度以ISO 8601格式存储的UTC时间戳：YYYY-MM-DDTHH:MM:SS.MMMZ
   final String KEY_UPDATED_AT = "updatedAt";
   final String KEY_CREATED_AT = "createdAt";
   final String KEY_OBJECT_ID = "objectId";

   ParseObject.map(Map map){
     objectId=map[KEY_OBJECT_ID];
     createdAt=map[KEY_CREATED_AT];
     updatedAt=map[KEY_UPDATED_AT];
   }

    String className;
    String objectId;
    num createdAt;
    num updatedAt;
    HashMap<String, Object> serverData;
    Set<String> availableKeys;
    bool isComplete;

    var url="";

    ParseObject(this.className){
      url=Parse.it().serverUrl+"/parse/classes/$className";
      serverData=new HashMap();

    }

    void put(String key,Object vlue){
      serverData[key]=vlue;
    }

    void putAll(Map<String,Object> datas){
      serverData.addEntries(datas.entries);
    }

    void remove(String key){
      serverData.remove(key);

    }

    void save() async{
      var headers={"X-Parse-Application-Id":Parse.it().appId,
        "Content-Type": "application/json"};
      var jsonStr=json.encode(serverData);
      print("jsonStr:$jsonStr");
     http.post(url,headers: headers,body: jsonStr).then((response){
        print(response.body);

    });
    }
}