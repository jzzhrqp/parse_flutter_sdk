
/// 验证邮箱合法性
bool validityEmail(String email){
  var exp=new RegExp("^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}\$");
 return exp.hasMatch(email);
}

/// 验证手机号码合法性
bool validityPhone(String phone){
  var exp=new RegExp("^1[3-8]\\d{9}\$");
  return exp.hasMatch(phone);
}

/// 验证密码合法性
bool validityPassword(String password){
  if(password==null) return false;
  return password.length>=6;
}