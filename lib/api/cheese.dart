import 'dart:convert';
import 'dart:io';
import 'package:cheese_flutter/common/notifiers.dart';
import 'package:cheese_flutter/common/page.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/index.dart';
import '../common/global.dart';

class Cheese {
  Cheese([this.context]) {
    _options = Options(extra: {"context": context});
  }

  BuildContext context;

  Options _options;

  static PersistCookieJar cookieJar;

  static CookieManager cookieManager;

  static Dio dio = new Dio(BaseOptions(
    baseUrl: 'http://192.168.1.13:8080/cheese',
    headers: {
      HttpHeaders.acceptHeader: "application/json",
    },
    // contentType: ContentType(primaryType, subType)
  ));

  static void init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);
    cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
    cookieManager = CookieManager(cookieJar);
    print(appDocPath);
    dio.interceptors.add(cookieManager);

    // 添加缓存插件
    // dio.interceptors.add(Global.netCache);
    // 设置用户token（可能为null，代表未登录）
    dio.options.headers[HttpHeaders.authorizationHeader] = Global.profile.token;
    // 在调试模式下需要抓包调试，所以我们使用代理，并禁用HTTPS证书校验
    // if (!Global.isRelease) {
    //   (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (client) {
    //     client.findProxy = (uri) {
    //       return "PROXY 10.1.10.250:8888";
    //     };
    //     //代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
    //     client.badCertificateCallback =
    //         (X509Certificate cert, String host, int port) => true;
    //   };
    // }
  }

  // Future getGithubUser() async {
  //   Response response = await dio.get("/users/xxxcrel");
  //   print(response.data);
  // }

  static Future<Result> getVerifyCode(String email) async {
    Response response =
        await dio.get("/code/email", queryParameters: {"address": email});

    var cookies = cookieJar.loadForRequest(response.request.uri);
    print(CookieManager.getCookies(cookies));

    return Result.fromJson(response.data);
  }

  static Future<Result> register(Map<String, dynamic> registerInfo) async {
    FormData reigsterForm = FormData.fromMap(registerInfo);
    Response response = await dio.post("/register", data: reigsterForm);
    return Result.fromJson(response.data);
  }

  static Future<Result> login(String username, String password) async {
    String jwtToken;
    var loginForm = {"username": username, "password": password};
    Response response = await dio.post("/login",
        data: loginForm,
        options: Options(contentType: Headers.formUrlEncodedContentType));
    jwtToken = response.headers[HttpHeaders.authorizationHeader][0];
    //登录成功后更新公共头（authorization），此后的所有请求都会带上用户身份信息
    dio.options.headers[HttpHeaders.authorizationHeader] = jwtToken;
    //清空所有缓存
    // Global.netCache.cache.clear();
    //更新profile中的token信息
    Global.profile.token = jwtToken;

    return Result.fromJson(response.data);
  }

  static Future<User> getUserInfo() async {
    Response response = await dio.get("/user");
    return User.fromJson(response.data);
  }

  static Future<Result> publishBubble(MultipartFile metaData,
      {Map<String, String> fileMappings}) async {
    List<MultipartFile> images = <MultipartFile>[];
    //TODO: file sync can't get image
    fileMappings.forEach((key, value) {
      images.add(MultipartFile.fromFileSync(key, filename: value));
    });
    FormData postForm = FormData.fromMap({
      "meta-data": metaData,
      "images": images
      // MultipartFile.fromFileSync("/data/user/0/com.example.cheese_flutter/cache/1758880_Screenshot_20200705_022530_com.netease.cloudmusic.jpg", filename: "bubble.jpg")
    });
    Response response = await dio.post("/user/posts",
        data: postForm,
        options:
            Options(headers: {Headers.contentTypeHeader: "multipart/mixed"}));
    print(response.data);
    return Result.fromJson(response.data);
  }

  static Future<Result> addReview(int postId, String content,
      {int parentId}) async {
    var reviewJson = {"content": content, "parentId": parentId};
    Response response = await dio.post("/posts/$postId/comments",
        data: reviewJson, options: Options(contentType: "multipart/mixed"));
    return Result.fromJson(response.data);
  }

  static Future<CategoryList> getCategoryList({PageParameter page}) async {
    Response response = await dio.get("/categories");
    return CategoryList.fromJson(response.data);
  }

  static Future<BubbleList> getBubbleListOfCategory(String category,
      {PageParameter page}) async {
    Response response = await dio.get("/categories/$category/posts");
    return BubbleList.fromJson(response.data);
  }
}