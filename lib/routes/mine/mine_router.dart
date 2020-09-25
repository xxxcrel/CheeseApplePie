import 'package:cheese_flutter/routes/i_router.dart';
import 'package:cheese_flutter/routes/mine/page/mine_page.dart';
import 'package:cheese_flutter/routes/mine/page/settings_page.dart';
import 'package:cheese_flutter/routes/mine/page/theme_page.dart';
import 'package:cheese_flutter/routes/routers.dart';
import 'package:fluro/fluro.dart';

class MineRouter extends IRouterProvider{
  static String minePage = "/mine";
  static String settingsPage = "/mine/settings";
  static String themePage = "/mine/settings/theme";

  void initRouter(Router router){
    router.define(minePage, handler: Handler(handlerFunc: (_,__) => MinePage()));
    router.define(settingsPage, handler: Handler(handlerFunc: (_, params) => SettingsPage()));
    router.define(themePage, handler: Handler(handlerFunc: (_,__) => ThemePage()));
  }
}