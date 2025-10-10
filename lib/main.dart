import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'responsive_ui.dart';
import 'package:toastification/toastification.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色
      statusBarIconBrightness: Brightness.light, // 状态栏图标颜色
    ),
  );
  runApp(const ToastificationWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GratisHub Issue Blog',
      // 静态主题：颜色、组件样式等
      theme: AppTheme.themeData,
      // 动态层：只覆盖 textTheme，窗口 resize 时才会重新算
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0),
            ).clamp(minScaleFactor: 0.1, maxScaleFactor: 1.15),
          ),
          child: Theme(
            data: AppTheme.themeData.copyWith(
              textTheme: AppTheme.responsiveTextTheme(context),
            ),
            child: child!,
          ),
        );
      },
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        // 仅当有背景图 / html设置了background 才用透明
        backgroundColor: Colors.white, // 不然在windows下是黑色
        body: SafeArea(
          // 手机上避开刘海等区域
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppTheme.maxPageWidth,
              ),
              child: Container(
                decoration: BoxDecoration(
                  // 充当屏幕过宽的分割线
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                  // 主内容区域的渐变背景色
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.themeData.scaffoldBackgroundColor,
                      Colors.white,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
                child: ResponsiveUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
