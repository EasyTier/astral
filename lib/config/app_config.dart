import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 配置模型基类
abstract class ConfigModel {
  Map<String, dynamic> toJson();
  String get configKey; // 配置在存储中的键名
}

// 添加高级配置类
class AdvancedConfig implements ConfigModel {
  final String defaultProtocol;
  final String devName;
  final bool enableEncryption;
  final bool enableIpv6;
  final int mtu;
  final bool latencyFirst;
  final bool enableExitNode;
  final bool proxyForwardBySystem;
  final bool noTun;
  final bool useSmoltcp;
  final String relayNetworkWhitelist;
  final bool disableP2p;
  final bool relayAllPeerRpc;
  final bool disableUdpHolePunching;
  final bool multiThread;
  final String dataCompressAlgo;
  final bool bindDevice;
  final bool enableKcpProxy;
  final bool disableKcpInput;
  final bool disableRelayKcp;

  @override
  String get configKey => 'advanced';

  AdvancedConfig({
    this.defaultProtocol = "tcp",
    this.devName = "",
    this.enableEncryption = true,
    this.enableIpv6 = true,
    this.mtu = 1380,
    this.latencyFirst = false,
    this.enableExitNode = false,
    this.proxyForwardBySystem = false,
    this.noTun = false,
    this.useSmoltcp = false,
    this.relayNetworkWhitelist = "*",
    this.disableP2p = false,
    this.relayAllPeerRpc = false,
    this.disableUdpHolePunching = false,
    this.multiThread = true,
    this.dataCompressAlgo = "None",
    this.bindDevice = true,
    this.enableKcpProxy = false,
    this.disableKcpInput = false,
    this.disableRelayKcp = true,
  });

  factory AdvancedConfig.fromJson(Map<String, dynamic> json) {
    return AdvancedConfig(
      defaultProtocol: json['defaultProtocol'] ?? "tcp",
      devName: json['devName'] ?? "",
      enableEncryption: json['enableEncryption'] ?? true,
      enableIpv6: json['enableIpv6'] ?? true,
      mtu: json['mtu'] ?? 1380,
      latencyFirst: json['latencyFirst'] ?? false,
      enableExitNode: json['enableExitNode'] ?? false,
      proxyForwardBySystem: json['proxyForwardBySystem'] ?? false,
      noTun: json['noTun'] ?? false,
      useSmoltcp: json['useSmoltcp'] ?? false,
      relayNetworkWhitelist: json['relayNetworkWhitelist'] ?? "*",
      disableP2p: json['disableP2p'] ?? false,
      relayAllPeerRpc: json['relayAllPeerRpc'] ?? false,
      disableUdpHolePunching: json['disableUdpHolePunching'] ?? false,
      multiThread: json['multiThread'] ?? true,
      dataCompressAlgo: json['dataCompressAlgo'] ?? "None",
      bindDevice: json['bindDevice'] ?? true,
      enableKcpProxy: json['enableKcpProxy'] ?? false,
      disableKcpInput: json['disableKcpInput'] ?? false,
      disableRelayKcp: json['disableRelayKcp'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'defaultProtocol': defaultProtocol,
        'devName': devName,
        'enableEncryption': enableEncryption,
        'enableIpv6': enableIpv6,
        'mtu': mtu,
        'latencyFirst': latencyFirst,
        'enableExitNode': enableExitNode,
        'proxyForwardBySystem': proxyForwardBySystem,
        'noTun': noTun,
        'useSmoltcp': useSmoltcp,
        'relayNetworkWhitelist': relayNetworkWhitelist,
        'disableP2p': disableP2p,
        'relayAllPeerRpc': relayAllPeerRpc,
        'disableUdpHolePunching': disableUdpHolePunching,
        'multiThread': multiThread,
        'dataCompressAlgo': dataCompressAlgo,
        'bindDevice': bindDevice,
        'enableKcpProxy': enableKcpProxy,
        'disableKcpInput': disableKcpInput,
        'disableRelayKcp': disableRelayKcp,
      };
}

// 配置模型类 - 保持原有结构
class ThemeConfig implements ConfigModel {
  final String mode;
  final int seedColor;

  @override
  String get configKey => 'theme';

  ThemeConfig({
    this.mode = 'system',
    this.seedColor = 0xFF2196F3, // Colors.blue.value
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      mode: json['mode'] ?? 'system',
      seedColor: json['seedColor'] ?? 0xFF2196F3,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'mode': mode,
        'seedColor': seedColor,
      };
}

class ServerConfig implements ConfigModel {
  final String url;
  final String name;
  final bool selected;
  final bool tcp;
  final bool udp;
  final bool ws;
  final bool wss;
  final bool quic;

  @override
  String get configKey => 'server';

  ServerConfig({
    required this.url,
    required this.name,
    this.selected = false,
    this.tcp = true,
    this.udp = true,
    this.ws = false,
    this.wss = false,
    this.quic = false,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      url: json['url'] ?? '',
      name: json['name'] ?? '',
      selected: json['selected'] ?? false,
      tcp: json['tcp'] ?? true,
      udp: json['udp'] ?? true,
      ws: json['ws'] ?? false,
      wss: json['wss'] ?? false,
      quic: json['quic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'name': name,
        'selected': selected,
        'tcp': tcp,
        'udp': udp,
        'ws': ws,
        'wss': wss,
        'quic': quic,
      };
}

// 创建一个新的服务器列表配置类
class ServerListConfig implements ConfigModel {
  final List<ServerConfig> servers;

  @override
  String get configKey => 'server';

  ServerListConfig({
    required this.servers,
  });

  factory ServerListConfig.fromJson(Map<String, dynamic> json) {
    List<ServerConfig> serverList = [];

    if (json['list'] is List) {
      try {
        serverList = (json['list'] as List).map((item) {
          // 安全地将 Map<dynamic, dynamic> 转换为 Map<String, dynamic>
          if (item is Map) {
            Map<String, dynamic> serverMap = {};
            item.forEach((key, value) {
              if (key is String) {
                serverMap[key] = value;
              }
            });
            return ServerConfig.fromJson(serverMap);
          }
          // 如果不是 Map，返回默认服务器配置
          return ServerConfig(
            url: 'public.easytier.cn:11010',
            name: '公共服务器',
            selected: true,
            tcp: true,
            udp: true,
            ws: false,
            wss: false,
            quic: false,
          );
        }).toList();

        // 确保至少有一个服务器被选中
        if (!serverList.any((server) => server.selected) &&
            serverList.isNotEmpty) {
          print('没有选中的服务器，将第一个服务器设为选中状态');
          serverList[0] = ServerConfig(
            url: serverList[0].url,
            name: serverList[0].name,
            selected: true,
            tcp: serverList[0].tcp,
            udp: serverList[0].udp,
            ws: serverList[0].ws,
            wss: serverList[0].wss,
            quic: serverList[0].quic,
          );
        } else {
          print('已有选中的服务器，保持原状');
        }
      } catch (e) {
        print('解析服务器列表失败: $e');
        // 解析失败时使用默认值
      }
    }

    // 如果列表为空，添加默认服务器
    if (serverList.isEmpty) {
      print('服务器列表为空，添加默认服务器');
      serverList = [
        ServerConfig(
          url: 'public.easytier.cn:11010',
          name: '公共服务器',
          selected: true,
          tcp: true,
          udp: true,
          ws: false,
          wss: false,
          quic: false,
        )
      ];
    }

    return ServerListConfig(servers: serverList);
  }

  @override
  Map<String, dynamic> toJson() => {
        'list': servers.map((server) => server.toJson()).toList(),
      };
}

class RoomConfig implements ConfigModel {
  final String name;
  final String password;

  @override
  String get configKey => 'room';

  RoomConfig({
    this.name = 'kevin',
    this.password = 'kevin',
  });

  factory RoomConfig.fromJson(Map<String, dynamic> json) {
    return RoomConfig(
      name: json['name'] ?? 'kevin',
      password: json['password'] ?? 'kevin',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'password': password,
      };
}

class UserConfig implements ConfigModel {
  final String name;

  @override
  String get configKey => 'user';

  UserConfig({
    required this.name,
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      name: json['name'] ?? Platform.localHostname,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class NetworkConfig implements ConfigModel {
  final String virtualIP;
  final bool dynamicIP;

  @override
  String get configKey => 'network';

  NetworkConfig({
    this.virtualIP = '',
    this.dynamicIP = true,
  });

  factory NetworkConfig.fromJson(Map<String, dynamic> json) {
    return NetworkConfig(
      virtualIP: json['virtualIP'] ?? '',
      dynamicIP: json['dynamicIP'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'virtualIP': virtualIP,
        'dynamicIP': dynamicIP,
      };
}

class SystemConfig implements ConfigModel {
  final bool closeToTray;
  final bool enablePing;

  @override
  String get configKey => 'system';

  SystemConfig({
    this.closeToTray = true,
    this.enablePing = true,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      closeToTray: json['closeToTray'] ?? true,
      enablePing: json['enablePing'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'closeToTray': closeToTray,
        'enablePing': enablePing,
      };
}

// 配置管理器
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  static late Box _configBox;
  static late String _configDirectory;
  static bool _initialized = false;

  // 配置模型映射表
  final Map<Type, ConfigModel> _configModels = {};

  // 配置类型与工厂函数映射
  final Map<Type, Function> _configFactories = {};

  factory AppConfig() {
    return _instance;
  }

  // 在AppConfig类中添加静态方法setConfigDir
  static void setConfigDir(String dirPath) {
    _configDirectory = dirPath;
    print('配置目录已设置为: $_configDirectory');
  }

  AppConfig._internal() {
    // 注册所有配置类型
    _registerConfig<ThemeConfig>(
      (json) => ThemeConfig.fromJson(json),
      ThemeConfig(),
    );

    _registerConfig<RoomConfig>(
      (json) => RoomConfig.fromJson(json),
      RoomConfig(),
    );

    _registerConfig<UserConfig>(
      (json) => UserConfig.fromJson(json),
      UserConfig(name: Platform.localHostname),
    );

    _registerConfig<NetworkConfig>(
      (json) => NetworkConfig.fromJson(json),
      NetworkConfig(),
    );

    _registerConfig<SystemConfig>(
      (json) => SystemConfig.fromJson(json),
      SystemConfig(),
    );

    // 注册服务器列表配置
    _registerConfig<ServerListConfig>(
      (json) => ServerListConfig.fromJson(json),
      ServerListConfig(servers: [
        ServerConfig(
          url: 'public.easytier.cn:11010',
          name: '公共服务器',
          selected: true,
          tcp: true,
          udp: true,
          ws: false,
          wss: false,
          quic: false,
        )
      ]),
    );

    // 注册高级配置
    _registerConfig<AdvancedConfig>(
      (json) => AdvancedConfig.fromJson(json),
      AdvancedConfig(),
    );
  }

  // 注册配置类型
  void _registerConfig<T extends ConfigModel>(
    T Function(Map<String, dynamic>) fromJson,
    T defaultValue,
  ) {
    _configFactories[T] = fromJson;
    _configModels[T] = defaultValue;
  }

  static Future<void> init() async {
    if (_initialized) return;

    try {
      // 如果没有预先设置配置目录，则尝试获取可执行文件所在目录
      if (!_configDirectory.isNotEmpty) {
        _configDirectory = File(Platform.resolvedExecutable).parent.path;
      }
      print('配置目录: $_configDirectory');

      // 初始化Hive
      await Hive.initFlutter(_configDirectory);
      print('Hive初始化完成');

      // 打开配置Box
      _configBox = await Hive.openBox('app_config');
      print('配置Box打开成功，包含 ${_configBox.length} 个条目');

      // 打印所有键值，用于调试
      print('配置Box中的所有键: ${_configBox.keys.toList()}');

      // 先创建实例并注册所有配置类型
      // 由于AppConfig是单例模式，这里不需要显式创建实例

      // 加载并验证配置
      await _instance._loadAndValidateConfig();
      print('配置加载和验证完成');

      _initialized = true;
    } catch (e) {
      print('AppConfig初始化失败: $e');
      // 尝试使用备用目录
      try {
        // 使用应用文档目录作为备用目录
        final appDocDir = Directory(path.join(
          Directory.current.path,
          'config',
        ));

        // 确保目录存在
        if (!appDocDir.existsSync()) {
          appDocDir.createSync(recursive: true);
        }

        _configDirectory = appDocDir.path;
        print('尝试使用备用目录: $_configDirectory');

        await Hive.initFlutter(_configDirectory);
        _configBox = await Hive.openBox('app_config');

        await _instance._loadAndValidateConfig();
        _initialized = true;
        print('使用备用目录初始化成功');
      } catch (e2) {
        print('备用初始化也失败: $e2');
        rethrow;
      }
    }
  }

  // 加载并验证所有配置
  Future<void> _loadAndValidateConfig() async {
    print('开始加载配置...');
    // 加载所有注册的配置
    for (var entry in _configFactories.entries) {
      final type = entry.key;
      final fromJson = entry.value;
      final defaultValue = _configModels[type]!;
      final configKey = defaultValue.configKey;

      print('加载配置: $configKey (${type.toString()})');
      _configModels[type] = _loadConfig(
        configKey,
        fromJson as ConfigModel Function(Map<String, dynamic>),
        defaultValue,
      );
    }

    // 更新服务器列表缓存
    _serverConfigs = (getModel<ServerListConfig>()).servers;
    print('服务器列表缓存更新完成，共 ${_serverConfigs.length} 个服务器');

    // 打印服务器列表，用于调试
    for (var server in _serverConfigs) {
      print(
          '服务器: ${server.name} (${server.url}), 选中: ${server.selected}, 协议: TCP=${server.tcp}, UDP=${server.udp}, WS=${server.ws}, WSS=${server.wss}, QUIC=${server.quic}');
    }
  }

  // 通用配置加载方法
  T _loadConfig<T extends ConfigModel>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
    T defaultValue,
  ) {
    final dynamic config = _configBox.get(key);
    print('读取配置 $key: ${config != null ? '存在' : '不存在'}');

    if (config != null) {
      try {
        print('配置内容: $config');
        final result = fromJson(Map<String, dynamic>.from(config));
        print('配置解析成功');
        return result;
      } catch (e) {
        print('配置解析失败: $e');
        // 如果解析失败，使用默认值
      }
    }

    // 保存默认值
    final defaultMap = defaultValue.toJson();
    print('使用默认配置: $defaultMap');
    _configBox.put(key, defaultMap);

    return defaultValue;
  }

  // 获取配置
  T getModel<T extends ConfigModel>() {
    if (!_configModels.containsKey(T)) {
      throw Exception('未注册的配置类型: $T');
    }
    return _configModels[T] as T;
  }

  // 更新配置
  Future<void> updateModel<T extends ConfigModel>(T newConfig) async {
    if (!_configModels.containsKey(T)) {
      throw Exception('未注册的配置类型: $T');
    }

    _configModels[T] = newConfig;
    await _configBox.put(newConfig.configKey, newConfig.toJson());
  }

  // 缓存的服务器配置列表
  late List<ServerConfig> _serverConfigs;

  // 保存服务器列表
  Future<void> _saveServerList() async {
    try {
      // 打印调试信息
      print('保存服务器列表: ${_serverConfigs.length} 个服务器');

      // 确保配置模型已更新
      await updateModel<ServerListConfig>(
          ServerListConfig(servers: _serverConfigs));

      // 强制刷新 Hive 存储
      await _configBox.flush();

      print('服务器列表保存完成');
    } catch (e) {
      print('保存服务器列表时出错: $e');
    }
  }

  // 以下是为了保持原有API的getter和setter

  // 主题设置
  ThemeConfig get theme => getModel<ThemeConfig>();

  ThemeMode get themeMode {
    final String mode = theme.mode.toLowerCase();
    return ThemeMode.values.firstWhere(
      (m) => m.toString().split('.').last.toLowerCase() == mode,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode.toString().split('.').last.toLowerCase();
    await updateModel<ThemeConfig>(ThemeConfig(
      mode: modeString,
      seedColor: theme.seedColor,
    ));
  }

  // 主题色设置
  Color get seedColor => Color(theme.seedColor);

  Future<void> setSeedColor(Color color) async {
    await updateModel<ThemeConfig>(ThemeConfig(
      mode: theme.mode,
      seedColor: color.value,
    ));
  }

  // 服务器列表设置
  List<Map<String, dynamic>> get serverList {
    return _serverConfigs.map((server) => server.toJson()).toList();
  }

  Future<void> setServerList(List<Map<String, dynamic>> servers) async {
    try {
      print('设置服务器列表: ${servers.length} 个服务器');

      _serverConfigs = servers.map((server) {
        // 确保所有必要的字段都存在
        return ServerConfig(
          url: server['url'] ?? '',
          name: server['name'] ?? '',
          selected: server['selected'] ?? false,
          tcp: server['tcp'] ?? true,
          udp: server['udp'] ?? true,
          ws: server['ws'] ?? false,
          wss: server['wss'] ?? false,
          quic: server['quic'] ?? false,
        );
      }).toList();

      await _saveServerList();

      // 打印保存后的服务器列表，用于调试
      print(
          '服务器列表已更新: ${_serverConfigs.map((s) => '${s.name}(${s.url})').join(', ')}');
    } catch (e) {
      print('设置服务器列表时出错: $e');
    }
  }

  // 房间配置
  RoomConfig get room => getModel<RoomConfig>();
  String get roomName => room.name;
  String get roomPassword => room.password;

  Future<void> setRoomName(String name) async {
    await updateModel<RoomConfig>(RoomConfig(
      name: name,
      password: room.password,
    ));
  }

  Future<void> setRoomPassword(String password) async {
    await updateModel<RoomConfig>(RoomConfig(
      name: room.name,
      password: password,
    ));
  }

  // 用户配置
  UserConfig get user => getModel<UserConfig>();
  String get username => user.name;

  Future<void> setUsername(String name) async {
    await updateModel<UserConfig>(UserConfig(name: name));
  }

  // 网络配置
  NetworkConfig get network => getModel<NetworkConfig>();
  String get virtualIP => network.virtualIP;
  bool get dynamicIP => network.dynamicIP;

  Future<void> setVirtualIP(String ip) async {
    await updateModel<NetworkConfig>(NetworkConfig(
      virtualIP: ip,
      dynamicIP: network.dynamicIP,
    ));
  }

  Future<void> setDynamicIP(bool enabled) async {
    await updateModel<NetworkConfig>(NetworkConfig(
      virtualIP: network.virtualIP,
      dynamicIP: enabled,
    ));
  }

  // 系统配置
  SystemConfig get system => getModel<SystemConfig>();
  bool get closeToTray => system.closeToTray;
  bool get enablePing => system.enablePing;

  Future<void> setCloseToTray(bool enabled) async {
    await updateModel<SystemConfig>(SystemConfig(
      closeToTray: enabled,
      enablePing: system.enablePing,
    ));
  }

  Future<void> setEnablePing(bool enabled) async {
    await updateModel<SystemConfig>(SystemConfig(
      closeToTray: system.closeToTray,
      enablePing: enabled,
    ));
  }

  // 通用配置获取方法
  T? getConfig<T>(String key) {
    return _configBox.get(key) as T?;
  }

  // 通用配置设置方法
  Future<void> setConfig<T>(String key, T value) async {
    await _configBox.put(key, value);

    // 更新缓存的配置对象
    await _loadAndValidateConfig();
  }

  // 高级配置
  AdvancedConfig get advanced => getModel<AdvancedConfig>();

  // 高级配置 getter
  String get defaultProtocol => advanced.defaultProtocol;
  String get devName => advanced.devName;
  bool get enableEncryption => advanced.enableEncryption;
  bool get enableIpv6 => advanced.enableIpv6;
  int get mtu => advanced.mtu;
  bool get latencyFirst => advanced.latencyFirst;
  bool get enableExitNode => advanced.enableExitNode;
  bool get proxyForwardBySystem => advanced.proxyForwardBySystem;
  bool get noTun => advanced.noTun;
  bool get useSmoltcp => advanced.useSmoltcp;
  String get relayNetworkWhitelist => advanced.relayNetworkWhitelist;
  bool get disableP2p => advanced.disableP2p;
  bool get relayAllPeerRpc => advanced.relayAllPeerRpc;
  bool get disableUdpHolePunching => advanced.disableUdpHolePunching;
  bool get multiThread => advanced.multiThread;
  String get dataCompressAlgo => advanced.dataCompressAlgo;
  bool get bindDevice => advanced.bindDevice;
  bool get enableKcpProxy => advanced.enableKcpProxy;
  bool get disableKcpInput => advanced.disableKcpInput;
  bool get disableRelayKcp => advanced.disableRelayKcp;

  // 高级配置 setter 方法
  Future<void> setDefaultProtocol(String value) async {
    await updateModel<AdvancedConfig>(AdvancedConfig(
      defaultProtocol: value,
      devName: advanced.devName,
      enableEncryption: advanced.enableEncryption,
      enableIpv6: advanced.enableIpv6,
      mtu: advanced.mtu,
      latencyFirst: advanced.latencyFirst,
      enableExitNode: advanced.enableExitNode,
      proxyForwardBySystem: advanced.proxyForwardBySystem,
      noTun: advanced.noTun,
      useSmoltcp: advanced.useSmoltcp,
      relayNetworkWhitelist: advanced.relayNetworkWhitelist,
      disableP2p: advanced.disableP2p,
      relayAllPeerRpc: advanced.relayAllPeerRpc,
      disableUdpHolePunching: advanced.disableUdpHolePunching,
      multiThread: advanced.multiThread,
      dataCompressAlgo: advanced.dataCompressAlgo,
      bindDevice: advanced.bindDevice,
      enableKcpProxy: advanced.enableKcpProxy,
      disableKcpInput: advanced.disableKcpInput,
      disableRelayKcp: advanced.disableRelayKcp,
    ));
  }

  Future<void> setDevName(String value) async {
    await updateModel<AdvancedConfig>(AdvancedConfig(
      defaultProtocol: advanced.defaultProtocol,
      devName: value,
      enableEncryption: advanced.enableEncryption,
      enableIpv6: advanced.enableIpv6,
      mtu: advanced.mtu,
      latencyFirst: advanced.latencyFirst,
      enableExitNode: advanced.enableExitNode,
      proxyForwardBySystem: advanced.proxyForwardBySystem,
      noTun: advanced.noTun,
      useSmoltcp: advanced.useSmoltcp,
      relayNetworkWhitelist: advanced.relayNetworkWhitelist,
      disableP2p: advanced.disableP2p,
      relayAllPeerRpc: advanced.relayAllPeerRpc,
      disableUdpHolePunching: advanced.disableUdpHolePunching,
      multiThread: advanced.multiThread,
      dataCompressAlgo: advanced.dataCompressAlgo,
      bindDevice: advanced.bindDevice,
      enableKcpProxy: advanced.enableKcpProxy,
      disableKcpInput: advanced.disableKcpInput,
      disableRelayKcp: advanced.disableRelayKcp,
    ));
  }

  // 更新高级配置的通用方法
  Future<void> updateAdvancedConfig({
    String? defaultProtocol,
    String? devName,
    bool? enableEncryption,
    bool? enableIpv6,
    int? mtu,
    bool? latencyFirst,
    bool? enableExitNode,
    bool? proxyForwardBySystem,
    bool? noTun,
    bool? useSmoltcp,
    String? relayNetworkWhitelist,
    bool? disableP2p,
    bool? relayAllPeerRpc,
    bool? disableUdpHolePunching,
    bool? multiThread,
    String? dataCompressAlgo,
    bool? bindDevice,
    bool? enableKcpProxy,
    bool? disableKcpInput,
    bool? disableRelayKcp,
  }) async {
    await updateModel<AdvancedConfig>(AdvancedConfig(
      defaultProtocol: defaultProtocol ?? advanced.defaultProtocol,
      devName: devName ?? advanced.devName,
      enableEncryption: enableEncryption ?? advanced.enableEncryption,
      enableIpv6: enableIpv6 ?? advanced.enableIpv6,
      mtu: mtu ?? advanced.mtu,
      latencyFirst: latencyFirst ?? advanced.latencyFirst,
      enableExitNode: enableExitNode ?? advanced.enableExitNode,
      proxyForwardBySystem:
          proxyForwardBySystem ?? advanced.proxyForwardBySystem,
      noTun: noTun ?? advanced.noTun,
      useSmoltcp: useSmoltcp ?? advanced.useSmoltcp,
      relayNetworkWhitelist:
          relayNetworkWhitelist ?? advanced.relayNetworkWhitelist,
      disableP2p: disableP2p ?? advanced.disableP2p,
      relayAllPeerRpc: relayAllPeerRpc ?? advanced.relayAllPeerRpc,
      disableUdpHolePunching:
          disableUdpHolePunching ?? advanced.disableUdpHolePunching,
      multiThread: multiThread ?? advanced.multiThread,
      dataCompressAlgo: dataCompressAlgo ?? advanced.dataCompressAlgo,
      bindDevice: bindDevice ?? advanced.bindDevice,
      enableKcpProxy: enableKcpProxy ?? advanced.enableKcpProxy,
      disableKcpInput: disableKcpInput ?? advanced.disableKcpInput,
      disableRelayKcp: disableRelayKcp ?? advanced.disableRelayKcp,
    ));
  }
}
