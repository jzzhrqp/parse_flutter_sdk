import 'dart:async';
import 'dart:convert';
import 'package:parse_flutter_sdk/validity_tool.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'parse.dart';
import 'parse_object.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParseUser extends ParseObject{
 static  final String KEY_SESSION_TOKEN = "sessionToken";
  final String KEY_AUTH_DATA = "authData";
  final String KEY_USERNAME = "username";
  final String KEY_PASSWORD = "password";
  final String KEY_EMAIL = "email";
  static Map<String,String> currentUserHeader;
  var username="";
  ParseUser() : super("user"){
    this.url=Parse.it().serverUrl+"/users";
  }

  /// 邮箱注册
  Future<Map> signUpByMail(String email,String password)async{
   var data={"email":email,"password":password};
   putAll(data);
   return signUp().then((map){
     print("邮箱注册返回：${map.toString()}");
   });
 }

 /// 注册
 ///
 /// 填写了email的，如果后端配置了要求验证邮件地址的，在注册成功后需要在电子邮箱进行邮件确认
 Future<Map> signUp() async {
    return _signUp(serverData);
 }
 /// 注册
 Future<Map> _signUp(Map<String, Object> data) async{
    Map validityResult=_validityRegisterData(data);
    if(!validityResult["bool"]) {    //数据验证没有通过，不进行注册
        throw new Exception(validityResult["msg"]);
    }

    var url=Parse.it().serverUrl+"/users";
    var header=Parse.it().publicHeader();
    header["X-Parse-Revocable-Session"]="1";
    return http.post(url,body: json.encode(data),headers: header).then((response){
      print("注册返回："+response.body);
      var data=json.decode(response.body);
      var objectId=data["objectId"];
      if(objectId==null){
        print("注册失败");
        throw new Exception(data["error"]);
      }else{
        print("注册成功,请在您的电子邮箱进行确认");
        return data;
      }
    });
 }

  /// 登录
  Future<Map> login(String username,String password) async {
    var header=Parse.it().publicHeader();
    header["X-Parse-Revocable-Session"]="1";
    var data="username=$username&password=$password";
    var url=Parse.it().serverUrl+"/login?$data";
    print(url);
    return http.get(url,headers: header)
        .then((http.Response response){
          print("登录返回结果："+response.body);
          var data=json.decode(response.body);
          var session=data[KEY_SESSION_TOKEN];
          if(session==null){
            throw new Exception(response.body);
          }else{
            print("登录成功");
            _saveCurrentUser(data);
            _saveCurrentUserSessionToken(session);
            return data;
          }
    });

  }

  ///请求重置密码
 ///
 /// 请求成功后，后台会发送一封电子邮件到用户账号的电子邮箱，点击邮件中的连接为账号设置新的密码
  static Future<Map> requestPasswordReset(String email) async{
    var url=Parse.it().serverUrl+"/requestPasswordReset";
    var data={"email":""+email};
    var header=Parse.it().publicHeader();
    return http.post(url,body: json.encode(data),headers: header).then((response){
      print("请求重置密码,body"+response.body+",statusCode:${response.statusCode}");
      var map=json.decode(response.body);
      if("{}"!=response.body){
        throw new Exception(map["error"]);
      }
      return map;
    });
  }

  /// 登出
  Future<String> logout(String sessionToken) async {
    currentUserHeader=null;
    var header=Parse.it().publicHeader();
    header["X-Parse-Session-Token"]=sessionToken;
    var url=Parse.it().serverUrl+"/logout";
    return http.post(url,headers: header).then((response){
      if (response.statusCode!=200){
        throw new Exception(response.body);
      };
      return response.body;
    });
  }

 /// 验证注册数据的合法性
 Map _validityRegisterData(Map data){
   var email=data["email"];
   if(email!=null){
     var b= validityEmail(email);
     print("邮箱$email 合法性：$b");
     if(!b) return {"bool":false,"msg":"邮箱格式不正确"};
   }
   var phone=data["phone"];
   if(phone!=null){
     var b=validityPhone(phone);
     print("手机号码$email 合法性：$b");
     if(!b) return {"bool":false,"msg":"手机号码式不正确"};
   }
   var username=data['username'];
   if (username==null) return {"bool":false,"msg":"username字段没有找到，不能进行注册"};
   var password=data["password"];
   if(password==null) return {"bool":false,"msg":"password字段没有找到，不能进行注册"};
   var b= validityPassword(password);
   if(!b) return {"bool":false,"msg":"密码格式不正确,密码最小长度6位"};

   return {"bool":true,"msg":"数据合法"};
 }

  /// 保存session到本地
  void _saveCurrentUserSessionToken(String session) async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    var oldSession=prefs.getString(KEY_SESSION_TOKEN);
    print("oldSession:$oldSession");
    if(oldSession!=null){
      logout(oldSession).then((d){
        print("登出旧session操作成功");
      });
    }
    await prefs.setString(KEY_SESSION_TOKEN, session);
    _createCurrentUserHeader(session);
  }

   void _saveCurrentUser(Map<String,Object> data){

   }

 static void _createCurrentUserHeader(String session){
    currentUserHeader=Parse.it().publicHeader()..["X-Parse-Session-Token"]=session;
  }

  /// 获取已登录用户头信息，用于其它的所有需要登录后才能进行操作的服务器请求
  static Future<Map<String, String>> getCurrentUserHeader()async {
    if(currentUserHeader==null){
      SharedPreferences prefs=await SharedPreferences.getInstance();
      var session=prefs.getString(KEY_SESSION_TOKEN);
      if(session!=null){
        _createCurrentUserHeader(session);
      }else{
        return  null;
      }
    }
    Map<String,String> header=new Map();
    header.addAll(currentUserHeader);
    return header;
  }

  /// ParseUser是否已在此设备上进行了身份验证。

 ///如果ParseUser是通过logIn或signUp方法获得的，那么这将是真的。
  static Future<bool> isAuthenticated() async{
   return getCurrentUserHeader().then((map){
      return map==null;
   });

  }


}
