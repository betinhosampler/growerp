/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:integration_test/integration_test.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_order_accounting/growerp_order_accounting.dart';
import 'package:order_accounting_example/main.dart' as router;
import 'package:order_accounting_example/main.dart';
import 'package:growerp_core/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  });

  testWidgets('''GrowERP payment purchase test''', (tester) async {
    await CommonTest.startTestApp(tester, router.generateRoute, menuOptions,
        OrderAccountingLocalizations.localizationsDelegates,
        title: 'Purchase payment Test',
        clear: true); // use data from previous run, ifnone same as true
    await CommonTest.createCompanyAndAdmin(tester, testData: {
      "companies": [
        company.copyWith(partyId: '_MOD_', name: initialCompany.name)
      ],
      "users": suppliers.sublist(0, 2),
    });
    // get above updated company
    await CommonTest.logout(tester);
    await CommonTest.login(tester);
    await PaymentTest.selectPurchasePayments(tester);
    await PaymentTest.addPayments(tester, purchasePayments.sublist(0, 4));
    await PaymentTest.updatePayments(tester, purchasePayments.sublist(4, 8));
    await PaymentTest.deleteLastPayment(tester);
    await PaymentTest.sendReceivePayment(tester);
    await PaymentTest.checkPaymentComplete(tester);
    await TransactionTest.selectTransactions(tester);
    await TransactionTest.checkTransactionComplete(tester);
  });
}
