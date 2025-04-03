import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform, Directory;
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'config/windowconfiguration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'utils/kv_state.dart';
import 'package:astral/utils/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化应用信息
  await AppInfoUtil.init();

  // 为Android平台设置配置目录
  if (Platform.isAndroid) {
    final appDir = await getApplicationDocumentsDirectory();
    AppConfig.setConfigDir(appDir.path);
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    // 设置窗口属性
    await setupWindow();
  }

  await AppConfig.init();
  // 初始化应用信息
  await RustLib.init();
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}
