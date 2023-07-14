/*
 * This software is in the public domain under CC0 1.0 Universal plus a
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

import 'package:growerp_core/growerp_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:growerp_core/test_data.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:hotel/router.dart' as router;
import 'package:hotel/menu_option_data.dart';
import 'package:hotel/main.dart';

import 'room_rental_test.dart';

Future<void> selectCheckInOut(WidgetTester tester) async {
  await CommonTest.selectOption(tester, '/checkInOut', 'FinDocsFormCheckIn');
}

Future<void> selectCheckOut(WidgetTester tester) async {
  await CommonTest.selectOption(
      tester, '/checkOut', 'FinDocsFormCheckOut', '2');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  DateTime today = CustomizableDateTime.current;
  var intlFormat = DateFormat('yyyy-MM-dd');
  String todayStringIntl = intlFormat.format(today);

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  });

  testWidgets("Test checkin >>>>>", (WidgetTester tester) async {
    await CommonTest.startTestApp(
      clear: true,
      title: 'Hotel reservation Test',
      tester,
      router.generateRoute,
      menuOptions,
      delegates,
    );
    await CommonTest.createCompanyAndAdmin(tester, testData: {
      "products": productsHotel,
      "assets": roomsHotel,
      "users": customers
    });
    await createRoomReservation(tester, roomReservations.sublist(0));
    await selectCheckInOut(tester);
    expect(find.byKey(const Key('finDocItem')), findsNWidgets(1));
    expect(CommonTest.getTextField('statusId0'), equals('Created'));
    await tester.tap(find.byKey(const Key('ID0')));
    await tester.pump(const Duration(seconds: 10));
    expect(CommonTest.getTextField('itemLine0'), contains(todayStringIntl));
    await tester.tap(find.byKey(const Key('nextStatus')));
    await tester.pump(const Duration(seconds: 10));
  }, skip: true);

  testWidgets("Test checkout >>>>>", (WidgetTester tester) async {
    // change the time
    CustomizableDateTime.customTime =
        DateTime.now().add(const Duration(days: 1));
    await selectCheckOut(tester);
    expect(find.byKey(const Key('FinDocsFormCheckOut')), findsOneWidget);
    // refresh screen
    await tester.drag(
        find.byKey(const Key('listView')), const Offset(0.0, 500.0));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byKey(const Key('finDocItem')), findsNWidgets(1));
    expect(CommonTest.getTextField('statusId0'), equals('Checked In'));
    await tester.tap(find.byKey(const Key('ID0')));
    await tester.pump(const Duration(seconds: 10));
    expect(CommonTest.getTextField('itemLine0'), contains(todayStringIntl));
    await tester.tap(find.byKey(const Key('nextStatus')));
    await tester.pump(const Duration(seconds: 10));
  }, skip: false);

  testWidgets("Test empty checkin and checkout >>>>>",
      (WidgetTester tester) async {
    await CommonTest.login(tester);
    await tester.tap(find.byKey(const Key('tap/checkInOut')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('finDocItem')), findsNothing);
    if (CommonTest.isPhone()) {
      await tester.tap(find.byTooltip('2'));
    } else {
      await tester.tap(find.byKey(const Key('tapFinDocsFormCheckOut')));
    }
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('finDocItem')), findsNothing);
  }, skip: false);
}
