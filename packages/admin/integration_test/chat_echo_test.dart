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

import 'package:admin/main.dart';
import 'package:core/api_repository.dart';
import 'package:core/domains/integration_test.dart';
import 'package:core/services/chat_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  });

  testWidgets("prepare empty system for chat test>>>>>>",
      (WidgetTester tester) async {
    await CommonTest.startApp(
      tester,
      TopApp(dbServer: APIRepository(), chatServer: ChatServer()),
      clear: true,
    );
    // userlogin in mainadmin data.dart should be used for chatecho
    await CompanyTest.createCompany(tester);
    await UserTest.selectAdministrators(tester);
    await UserTest.addAdministrators(tester, [administrators[0]], check: false);
  }, skip: true);
// now start chatEco_main.dart with the userlog in when the company created
  testWidgets("Chatroom maintenance>>>>>>", (WidgetTester tester) async {
    await CommonTest.startApp(
      tester,
      TopApp(dbServer: APIRepository(), chatServer: ChatServer()),
    );
    // chatrooms screen
    await CommonTest.tapByTooltip(tester, 'Chat');
    expect(find.byKey(Key('ChatRoomListDialog')), findsOneWidget);
    // open new chat
    await CommonTest.tapByKey(tester, 'addNew');
    expect(find.byKey(Key('ChatRoomDialog')), findsOneWidget);
    await CommonTest.tapByKey(tester, 'userDropDown');
    await CommonTest.tapByText(tester, 'administrator1');
    await CommonTest.tapByKey(tester, 'update');
    expect(find.byKey(Key('chatRoomItem')), findsNWidgets(1));
    // select created chat
    await CommonTest.tapByKey(tester, 'chatRoomName0');
    expect(find.byKey(Key('ChatDialog')), findsOneWidget);
    // enter chat message
    await CommonTest.enterText(tester, 'messageContent', 'hello!');
    await CommonTest.tapByKey(tester, 'send');
    expect(find.text('hello!'), findsOneWidget);
    // leave chatroom form
    await CommonTest.tapByKey(tester, 'cancel');
    // delete chatroom
    await CommonTest.tapByKey(tester, 'delete0');
    expect(find.byKey(Key('chatRoomItem')), findsNWidgets(0));
    // leave chatrooms form
    await CommonTest.tapByKey(tester, 'cancel');
  }, skip: true);
  testWidgets("chat with chat echo in other process>>>>>>",
      (WidgetTester tester) async {
    await CommonTest.startApp(
      tester,
      TopApp(dbServer: APIRepository(), chatServer: ChatServer()),
    );
//    await CommonTest.logout(tester);
//    await CommonTest.login(tester,
//        username: 'email3@example.org',
//        password: 'qqqqqq9!'); // chatrooms screen
    await CommonTest.tapByTooltip(tester, 'Chat');
    await CommonTest.refresh(tester);
    // open new chat
    await CommonTest.tapByKey(tester, 'addNew');
    await CommonTest.tapByKey(tester, 'userDropDown', seconds: 5);
    await CommonTest.tapByText(tester, 'John Doe');
    await CommonTest.tapByKey(tester, 'update', seconds: 5);
    // select created chat
    await CommonTest.tapByKey(tester, 'chatRoomName0');
    expect(find.byKey(Key('ChatDialog')), findsOneWidget);
    // enter chat message
    await CommonTest.enterText(tester, 'messageContent', 'hello!');
    await CommonTest.tapByKey(tester, 'send', seconds: 5);
    expect(find.text('hello!'), findsNWidgets(2));
  }, skip: false);
}
