import 'package:cheese_flutter/common/web_page_transitions.dart';
import 'package:cheese_flutter/res/colors.dart';
import 'package:cheese_flutter/res/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/index.dart';
import 'package:flutter/foundation.dart';

import '../common/global.dart';

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile(); //保存Profile变更
    super.notifyListeners(); //通知依赖的Widget更新
  }
}

class UserProvider extends ProfileChangeNotifier {
  User get user => _profile.user;

  // APP是否登录(如果有用户信息，则证明登录过)
  bool get isLogin => user != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
  set user(User user) {
    // print("profileid ${_profile.user.username}");
    if (user?.id != _profile.user?.id) {
      _profile.lastLogin = _profile.user?.username;
      _profile.user = user;
      print("change user");
      notifyListeners();
    }
  }
}

extension ThemeModeExtension on ThemeMode {
  String get value => ['System', 'Light', 'Dark'][index];
}

class ThemeProvider extends ProfileChangeNotifier {
  // //暂未发现用途
  // void syncTheme() {
  //   final String theme = _profile.theme;
  //   if (theme.isNotEmpty && theme != ThemeMode.system.value) {
  //     notifyListeners();
  //   }
  // }

  void setTheme(ThemeMode themeMode) {
    final String theme = themeMode.value;
    if (theme != _profile.theme) {
      _profile.theme = theme;
      notifyListeners();
    }
  }

  ThemeMode getThemeMode() {
    final String theme = _profile.theme;
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
      backgroundColor: isDarkMode ? Colours.dark_bg_gray : Colors.white,
      errorColor: isDarkMode ? Colours.dark_red : Colours.red,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      primaryColorLight:
          isDarkMode ? Colours.dark_material_bg : Colors.grey[200],
      //CircleAvatar使用
      primaryColorDark: isDarkMode ? Colours.dark_material_bg : Colours.bg_gray,
      accentColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      // Tab指示器颜色
      indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      // 页面背景色
      scaffoldBackgroundColor:
          isDarkMode ? Colours.dark_bg_gray : Colors.white,
      // 主要用于Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      // 文字选择色（输入框复制粘贴菜单）
      textSelectionColor: Colours.app_main.withAlpha(70),
      textSelectionHandleColor: Colours.app_main,
      primaryTextTheme: TextTheme(
        // TextField输入文字颜色
        subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        bodyText1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        subtitle2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        button: isDarkMode ? TextStyles.textDark : TextStyles.text,
        caption: isDarkMode ? TextStyles.textDark : TextStyles.text,
      ),
      textTheme: TextTheme(
        // TextField输入文字颜色
        subtitle1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        bodyText1: isDarkMode ? TextStyles.textDark : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        subtitle2: isDarkMode ? TextStyles.textDark : TextStyles.text,
        button: isDarkMode ? TextStyles.textDark : TextStyles.text,
        caption: isDarkMode ? TextStyles.textDark : TextStyles.text,
      ),
      // highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.red)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(style: BorderStyle.none)),
        fillColor: isDarkMode ? Colours.dark_material_bg : Colours.bg_gray,
        hintStyle: isDarkMode ? TextStyles.textDark : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0.0,
        //默认生成的leading button 颜色具体看AppBar源码
        iconTheme:
            IconThemeData(color: isDarkMode ? Colours.dark_text : Colours.text),
        textTheme: TextTheme(
            // Center Title的颜色
            // headline6: TextStyle(color: isDarkMode ? Colours.dark_text : Colours.text, fontSize: )
            headline6: isDarkMode ? TextStyle(fontSize: 18.0, color: Colours.dark_text) : TextStyle(fontSize: 18.0, color: Colours.text)),
        color: isDarkMode ? Colours.dark_bg_gray : Colors.white,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // selectedItemColor: Colors.amber,
          unselectedLabelStyle:
              isDarkMode ? TextStyles.textDarkGray12 : TextStyles.text,
          selectedLabelStyle:
              isDarkMode ? TextStyles.textDarkGray12 : TextStyles.text),
      dividerTheme: DividerThemeData(
          color: isDarkMode ? Colours.dark_line : Colours.line,
          space: 0.6,
          thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      pageTransitionsTheme: NoTransitionsOnWeb(),
    );
  }
}
// class ThemeModel extends ProfileChangeNotifier {
//   // 获取当前主题，如果为设置主题，则默认使用蓝色主题
//   ColorSwatch get theme => Global.theme
//       .firstWhere((e) => e.value == _profile.theme, orElse: () => Colors.blue);

//   // 主题改变后，通知其依赖项，新主题会立即生效
//   set theme(ColorSwatch color) {
//     if (color != theme) {
//       _profile.theme = color[500].value;
//       notifyListeners();
//     }
//   }
// }
