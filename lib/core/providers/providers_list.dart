import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app_provider.dart';
import 'auth_provider.dart';

List<SingleChildWidget> providers() {
  return [
    ChangeNotifierProvider(create: (_) => AppProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider())
  ];
}
