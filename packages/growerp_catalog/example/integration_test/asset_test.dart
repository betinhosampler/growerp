// ignore: depend_on_referenced_packages
import 'package:growerp_core/growerp_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:integration_test/integration_test.dart';
import 'package:growerp_catalog/growerp_catalog.dart';
import 'package:example/main.dart';
import 'package:growerp_catalog/growerp_catalog.dart' as catalog;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  });

  testWidgets('''GrowERP asset test''', (tester) async {
    await CommonTest.startTestApp(tester, generateRoute, menuOptions,
        clear: true); // use data from previous run, ifnone same as true
    await CompanyTest.createCompany(tester);
    await CategoryTest.selectCategories(tester);
    await CategoryTest.addCategories(tester, catalog.categories.sublist(0, 2),
        check: false);
    await ProductTest.selectProducts(tester);
    await ProductTest.addProducts(tester, catalog.products.sublist(0, 3),
        check: false);
    await AssetTest.selectAsset(tester);
    await AssetTest.addAssets(tester, catalog.assets);
    await AssetTest.updateAssets(tester);
    await AssetTest.deleteAssets(tester);
    await CommonTest.logout(tester);
  });
}
