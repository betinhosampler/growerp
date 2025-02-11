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

import 'dart:io';
import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../growerp_core.dart';
import '../../../../test_data.dart';

class CommonTest {
  String classificationId = GlobalConfiguration().get("classificationId");
  static int waitTime = 2;

  static Future<void> startTestApp(
      WidgetTester tester,
      Route<dynamic> Function(RouteSettings) router,
      List<MenuOption> menuOptions,
      List<LocalizationsDelegate> extraDelegates,
      {List<BlocProvider>? blocProviders,
      bool clear = false,
      String title = "Growerp testing..."}) async {
    int seq = Random.secure().nextInt(1024);
    SaveTest test = await PersistFunctions.getTest();
    // debugPrint("====startapp seq: $seq");
    if (clear == true) {
      await PersistFunctions.persistTest(SaveTest(sequence: seq));
    } else {
      await PersistFunctions.persistTest(test.copyWith(sequence: seq));
    }
    Bloc.observer = AppBlocObserver();
    runApp(TopApp(
      dbServer: APIRepository(),
      chatServer: ChatServer(),
      router: router,
      title: title,
      menuOptions: menuOptions,
      extraDelegates: extraDelegates,
      blocProviders: blocProviders ?? [],
    ));
    await tester.pumpAndSettle(Duration(seconds: waitTime));
  }

  static Future<void> createCompanyAndAdmin(WidgetTester tester,
      {bool demoData = false, Map testData = const {}}) async {
    SaveTest test = await PersistFunctions.getTest();
    int seq = test.sequence + 1;
    if (test.company != null) return; // company already created
    await CommonTest.logout(tester);
    // check if email address already exist
    APIRepository repos = APIRepository();
    var exist = true;
    var times = 0;
    while (exist) {
      ApiResult result =
          await repos.checkEmail(admin.email!.replaceFirst('XXX', '${++seq}'));
      exist = result.when(success: (data) => data, failure: (_) => false);
      expect(times++, lessThan(20),
          reason: "Could not find free email address");
    }

    await CommonTest.tapByKey(tester, 'newCompButton');
    await tester.pump(const Duration(seconds: 3));
    await CommonTest.enterText(tester, 'firstName', admin.firstName!);
    await CommonTest.enterText(tester, 'lastName', admin.lastName!);
    var email = admin.email!.replaceFirst('XXX', '$seq');
    await CommonTest.enterText(tester, 'email', email);

    String companyName = '${initialCompany.name!} $seq';
    await enterText(tester, 'companyName', companyName);
    await CommonTest.drag(tester);
    await enterDropDown(
        tester, 'currency', initialCompany.currency!.description!);
    await CommonTest.drag(tester);
    if (demoData == false) {
      await CommonTest.tapByKey(tester, 'demoData');
    } // no demo data
    await CommonTest.tapByKey(tester, 'newCompany', seconds: 3);
    // start with clean saveTest
    await PersistFunctions.persistTest(SaveTest(
      sequence: ++seq,
      nowDate: DateTime.now(), // used in rental
      admin: admin.copyWith(email: email, loginName: email),
      company: initialCompany.copyWith(email: email, name: companyName),
    ));
    await CommonTest.login(tester, testData: testData);
  }

  static checkCompanyAndAdmin(
    WidgetTester tester,
  ) async {
    SaveTest test = await PersistFunctions.getTest();
    // appbar
    expect(getTextField('appBarAvatarText'), equals(test.company!.name![0]));
    expect(getTextField('appBarCompanyName'), equals(test.company!.name));
    // company
    expect(getTextField('dbCompanyTitle'), equals("Company"));
    expect(getTextField('dbCompanySubTitle0'), equals(test.company!.name));
    expect(getTextField('dbCompanySubTitle1'),
        equals("Email: ${test.company!.email}"));
    expect(getTextField('dbCompanySubTitle2'),
        equals("Currency: ${test.company!.currency!.description}"));
    expect(getTextField('dbCompanySubTitle3'),
        equals("Employees: ${test.company!.employees.length + 1}"));
    // User
    expect(getTextField('dbUserTitle'), equals("Logged in User"));
    expect(getTextField('dbUserSubTitle0'),
        equals("${test.admin!.firstName} ${test.admin!.lastName}"));
    expect(
        getTextField('dbUserSubTitle1'), equals("Email: ${test.admin!.email}"));
    expect(getTextField('dbUserSubTitle2'), equals("Login name:"));
    expect(getTextField('dbUserSubTitle3'), equals(" ${test.admin!.email}"));
    expect(getTextField('dbUserSubTitle4'),
        equals("Security Group: ${test.admin!.userGroup!.name}"));
  }

  static takeScreenshot(WidgetTester tester,
      IntegrationTestWidgetsFlutterBinding binding, String name) async {
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
    }
    await binding.takeScreenshot(name);
  }

  static Future<void> selectOption(
      WidgetTester tester, String option, String formName,
      [String? tapNumber]) async {
    if (isPhone()) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pump(const Duration(seconds: 3));
    }
    debugPrint("=====incoming key: $option");
    if (!option.startsWith('tap')) {
      if (option.startsWith('db')) {
        // convert old mainscrean tapping to drawer on mobile
        option = "/${option.substring(2).toLowerCase()}";
      } else if (!option.startsWith('/')) {
        option = "/$option";
      }
      option = "tap$option";
    }
    debugPrint("=====looking for tap key: $option");
    await tapByKey(tester, option, seconds: 3);
    if (tapNumber != null) {
      if (isPhone()) {
        await tester.tap(find.byTooltip(tapNumber));
      } else {
        await tapByKey(tester, "tap$formName");
      }
      await tester.pumpAndSettle(Duration(seconds: waitTime));
    }
    await checkWidgetKey(tester, formName);
  }

  static Future<void> login(WidgetTester tester,
      {String? username,
      String? password,
      int days = 0,
      Map testData = const {}}) async {
    CustomizableDateTime.customTime = DateTime.now().add(Duration(days: days));
    SaveTest test = await PersistFunctions.getTest();
    if ((test.company == null || test.admin == null) &&
        (username == null || password == null)) {
      debugPrint("=========== Need company test to be run first");
      return;
    }
    if (find
        .byKey(const Key('HomeFormAuth'))
        .toString()
        .startsWith('zero widgets with key')) {
      await pressLoginWithExistingId(tester);
      await enterText(tester, 'username', username ?? test.admin!.email!);
      await enterText(tester, 'password', password ?? 'qqqqqq9!');
      await pressLogin(tester);
      await checkText(tester, 'Main'); // dashboard
    }
    String apiKey = CommonTest.getTextField('apiKey');
    String moquiSessionToken = CommonTest.getTextField('moquiSessionToken');
    await GlobalConfiguration()
        .add({"apiKey": apiKey, "moquiSessionToken": moquiSessionToken});
    int seq = test.sequence;
    if (!test.testDataLoaded && testData.isNotEmpty) {
      APIRepository repos = APIRepository();
      repos.setApiKey(apiKey, moquiSessionToken);
      // replace XXX strings
      Map parsed = {};
      testData.forEach((k, v) {
        List newList = [];
        v.forEach((item) {
          if (item is Company || item is User) {
            if (item.email != null) {
              item = item.copyWith(
                  email: item.email!.replaceFirst('XXX', '${seq++}'));
            }
          }
          if (item is User) {
            if (item.loginName != null) {
              item = item.copyWith(
                  loginName: item.loginName!.replaceFirst('XXX', '${seq++}'));
            }
          }
          newList.add(item);
        });
        parsed[k] = newList;
      });
      await repos.upLoadEntities(parsed);
    }
    await PersistFunctions.persistTest(
        test.copyWith(sequence: seq, testDataLoaded: true));
  }

  static Future<void> gotoMainMenu(WidgetTester tester) async {
    await selectMainMenu(tester, "tap/");
  }

  static Future<void> selectMainCompany(WidgetTester tester) async {
    await CommonTest.tapByKey(tester, 'tapCompany');
    await CommonTest.checkWidgetKey(tester, 'CompanyDialogOrgInternal');
  }

  static Future<void> doSearch(WidgetTester tester,
      {required String searchString, int? seconds}) async {
    seconds ??= waitTime;
    if (tester.any(find.byKey(const Key('searchButton'))) == false) {
      await tapByKey(tester, 'search');
    }
    await enterText(tester, 'searchField', searchString);
    await tapByKey(tester, 'searchButton', seconds: seconds);
  }

  static Future<void> closeSearch(WidgetTester tester) async {
    if (tester.any(find.byKey(const Key('searchButton'))) == true) {
      await tapByKey(tester, 'search');
    } // cancel search
  }

  static Future<void> pressLoginWithExistingId(WidgetTester tester) async {
    await tapByKey(tester, 'loginButton', seconds: 1);
  }

  static Future<void> pressLogin(WidgetTester tester) async {
    await tapByKey(tester, 'login', seconds: waitTime);
  }

  static Future<void> logout(WidgetTester tester) async {
    if (hasKey('HomeFormUnAuth')) return; // already logged out
    await gotoMainMenu(tester);
    if (hasKey('HomeFormAuth')) {
      debugPrint("Dashboard logged in , needs to logout");
      await tapByKey(tester, 'logoutButton');
      await tester.pump(Duration(seconds: waitTime));
      expect(find.byKey(const Key('HomeFormUnAuth')), findsOneWidget);
    }
  }

  // low level ------------------------------------------------------------

  static Future<bool> waitForKey(WidgetTester tester, String keyName) async {
    int times = 0;
    bool found = false;
    while (times++ < 10 && found == false) {
      found = tester.any(find.byKey(Key(keyName), skipOffstage: true));
      await tester.pump(const Duration(milliseconds: 500));
    }
    if (found) {
      debugPrint("=== waited for key $keyName to show: ${times * 0.5} seconds");
    }
    //expect(found, true,
    //    reason: 'key $keyName not found even after 6 seconds wait!');
    return found;
  }

  static Future<bool> waitForSnackbarToGo(WidgetTester tester) async {
    int times = 0;
    bool found = true;
    while (times++ < 10 && found == true) {
      found = tester.any(find.byType(SnackBar));
      await tester.pump(const Duration(milliseconds: 500));
    }
    if (!found) {
      debugPrint("=== waited for message to disappear: ${times * 0.5} seconds");
    }
//    expect(found, false,
//        reason: 'Snackbar still found, even after 6 seconds wait!');
    return found;
  }

  static Future<void> checkWidgetKey(WidgetTester tester, String widgetKey,
      [int count = 1]) async {
    expect(find.byKey(Key(widgetKey)), findsNWidgets(count));
  }

  static Future<bool> doesExistKey(WidgetTester tester, String widgetKey,
      [int count = 1]) async {
    if (find
        .byKey(Key(widgetKey))
        .toString()
        .startsWith('zero widgets with key')) return false;
    return true;
  }

  /// check if a particular text can be found on the page.
  static Future<void> checkText(WidgetTester tester, String text) async {
    expect(find.textContaining(RegExp(text, caseSensitive: false)).last,
        findsOneWidget);
  }

  /// [lowLevel]
  static Future<void> drag(WidgetTester tester,
      {int seconds = 1, String listViewName = 'listView'}) async {
    await tester.drag(
        find.byKey(Key(listViewName)).last, const Offset(0, -400));
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> dragUntil(WidgetTester tester,
      {String listViewName = 'listView', required String key}) async {
    int times = 0;
    bool found = false;
    do {
      await tester.drag(
          find.byKey(Key(listViewName)).last, const Offset(0, -400));
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      found = tester.any(find.byKey(Key(key)));
    } while (times++ < 10 && found == false);
//    await tester.pumpAndSettle();
    debugPrint("======dragged $times times");
  }

  /// [lowLevel]
  static Future<void> refresh(WidgetTester tester,
      {int? seconds, String listViewName = 'listView'}) async {
    seconds ??= waitTime;
    await tester.drag(find.byKey(Key(listViewName)).last, const Offset(0, 400));
    await tester.pump(Duration(seconds: seconds));
  }

  static Future<void> enterText(
      WidgetTester tester, String key, String value) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byKey(Key(key)), value);
    await tester.pump();
  }

  static Future<void> enterDropDownSearch(
      WidgetTester tester, String key, String value,
      {int seconds = 1}) async {
    await tapByKey(tester, key);
    await tester.enterText(find.byType(TextField).last, value);
    await tester
        .pumpAndSettle(Duration(seconds: waitTime)); // wait for search result
    await tester
        .tap(find.textContaining(RegExp(value, caseSensitive: false)).last);
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> enterDropDown(
      WidgetTester tester, String key, String value,
      {int seconds = 1}) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle(Duration(seconds: seconds));
    if (value.isEmpty) {
      await tester.tap(find.text(value).last);
    } else {
      await tester.tap(find.textContaining(value).last);
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  static String getDropdown(String key) {
    DropdownButtonFormField tff = find.byKey(Key(key)).evaluate().single.widget
        as DropdownButtonFormField;
    if (tff.initialValue is Currency) return tff.initialValue.description;
    if (tff.initialValue is UserGroup) return tff.initialValue.toString();
    if (tff.initialValue is Role) return tff.initialValue.value;
    return tff.initialValue;
  }

  static String getDropdownSearch(String key) {
    DropdownSearch tff =
        find.byKey(Key(key)).evaluate().single.widget as DropdownSearch;
    if (tff.selectedItem is Country) return tff.selectedItem.name;
    if (tff.selectedItem is Category) return tff.selectedItem.categoryName;
    if (tff.selectedItem is Product) return tff.selectedItem.productName;
    if (tff.selectedItem is User) return tff.selectedItem.company.name;
    return tff.selectedItem.toString();
  }

  /// get the content of a text field identified by a key
  static String getTextField(String key) {
    Text tf = find.byKey(Key(key)).evaluate().single.widget as Text;
    return tf.data!;
  }

  /// get the content of a TextFormField providing the key
  static String getTextFormField(String key) {
    TextFormField tff =
        find.byKey(Key(key)).evaluate().single.widget as TextFormField;
    return tff.controller!.text;
  }

  static bool getCheckbox(String key) {
    Checkbox tff = find.byKey(Key(key)).evaluate().single.widget as Checkbox;
    return tff.value ?? false;
  }

  static bool getCheckboxListTile(String text) {
    CheckboxListTile tff =
        find.text(text).evaluate().single.widget as CheckboxListTile;
    return tff.value ?? false;
  }

  static bool isPhone() {
    try {
      expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool hasKey(String key) {
    if (find.byKey(Key(key)).toString().startsWith('zero widgets with key')) {
      return false;
    }
    return true;
  }

  static Future<void> selectMainMenu(
      WidgetTester tester, String menuOption) async {
    if (hasKey('cancel')) {
      // company or user detail menu open?
      await tester.tap(find.byKey(const Key('cancel')).last);
      await tester.pump();
    }
    if (!hasKey('HomeFormAuth')) {
      if (isPhone()) {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pump();
        await tester.pumpAndSettle(Duration(seconds: waitTime));
      }
      await tapByKey(tester, menuOption);
    }
  }

  static Future<void> tapByKey(WidgetTester tester, String key,
      {int seconds = 1}) async {
    await tester.tap(find.byKey(Key(key)).last);
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> tapByWidget(WidgetTester tester, Widget widget,
      {int seconds = 1}) async {
    await tester.tap(find.byWidget(widget).first);
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> tapByType(WidgetTester tester, Type type,
      {int seconds = 1}) async {
    await tester.tap(find.byType(type).first);
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> tapByText(WidgetTester tester, String text,
      {int seconds = 1}) async {
    await tester
        .tap(find.textContaining(RegExp(text, caseSensitive: false)).last);
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> tapByTooltip(WidgetTester tester, String text,
      {int seconds = 1}) async {
    await tester.tap(find.byTooltip(text));
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  static Future<void> selectDropDown(
      WidgetTester tester, String key, String value,
      {seconds = 1}) async {
    await tapByKey(tester, key, seconds: seconds);
    await tapByText(tester, value);
  }

  static String getRandom() {
    Text tff = find
        .byKey(const Key('appBarCompanyName'))
        .evaluate()
        .single
        .widget as Text;
    return tff.data!.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static int getWidgetCountByKey(WidgetTester tester, String key) {
    var finder = find.byKey(Key(key));
    return tester.widgetList(finder).length;
  }

  static void mockPackageInfo() {
    const channel = MethodChannel('plugins.flutter.io/package_info');

    handler(MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{
          'appName': 'myapp',
          'packageName': 'com.mycompany.myapp',
          'version': '0.0.1',
          'buildNumber': '1'
        };
      }
      return null;
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  static void mockImagePicker() {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/image_picker');

    handler(MethodCall methodCall) async {
      ByteData data = await rootBundle.load('assets/images/crm.png');
      Uint8List bytes = data.buffer.asUint8List();
      Directory tempDir = await getTemporaryDirectory();
      File file = await File(
        '${tempDir.path}/tmp.tmp',
      ).writeAsBytes(bytes);
      debugPrint('=========${file.path}');
      return [
        // file.path;
        {
          'name': "Icon.png",
          'path': file.path,
          'bytes': bytes,
          'size': bytes.lengthInBytes,
        }
      ];
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  static void mockUrlLauncher() {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/url_launcher');

    handler(MethodCall methodCall) async {
      debugPrint("=========$methodCall");
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }
}
