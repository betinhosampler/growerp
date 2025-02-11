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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_inventory/growerp_inventory.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset('app_settings');
  Bloc.observer = AppBlocObserver();
  runApp(TopApp(
      dbServer: APIRepository(),
      chatServer: ChatServer(),
      title: 'GrowERP package: growerp_inventory.',
      router: generateRoute,
      menuOptions: menuOptions,
      extraDelegates: const [InventoryLocalizations.delegate]));
}

// Menu definition
List<MenuOption> menuOptions = [
  MenuOption(
    image: 'packages/growerp_core/images/dashBoardGrey.png',
    selectedImage: 'packages/growerp_core/images/dashBoard.png',
    title: 'Main',
    route: '/',
    readGroups: [UserGroup.admin, UserGroup.employee],
    writeGroups: [UserGroup.admin],
    child: const MainMenu(),
  ),
  MenuOption(
    image: 'packages/growerp_core/images/companyGrey.png',
    selectedImage: 'packages/growerp_core/images/company.png',
    title: 'Company',
    route: '/company',
    readGroups: [UserGroup.admin, UserGroup.employee],
    writeGroups: [UserGroup.admin],
    child: const MainMenu(),
  ),
  MenuOption(
      image: 'packages/growerp_core/images/supplierGrey.png',
      selectedImage: 'packages/growerp_core/images/supplier.png',
      title: 'Inventory',
      route: '/inventory',
      readGroups: [
        UserGroup.admin,
        UserGroup.employee,
      ],
      child: const LocationListForm()),
];

// routing
Route<dynamic> generateRoute(RouteSettings settings) {
  if (kDebugMode) {
    print('>>>NavigateTo { ${settings.name} '
        'with: ${settings.arguments.toString()} }');
  }
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(
          builder: (context) => HomeForm(menuOptions: menuOptions));
    case '/company':
      return MaterialPageRoute(
          builder: (context) => DisplayMenuOption(
              menuList: menuOptions, menuIndex: 1, tabIndex: 0));
    case '/inventory':
      return MaterialPageRoute(
          builder: (context) => DisplayMenuOption(
              menuList: menuOptions, menuIndex: 2, tabIndex: 0));
    default:
      return MaterialPageRoute(
          builder: (context) => FatalErrorForm(
              message: "Routing not found for request: ${settings.name}"));
  }
}

// main menu
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state.status == AuthStatus.authenticated) {
        Authenticate authenticate = state.authenticate!;
        return DashBoardForm(dashboardItems: [
          makeDashboardItem('dbCompany', context, menuOptions[1], [
            authenticate.company!.name!.length > 20
                ? "${authenticate.company!.name!.substring(0, 20)}..."
                : "${authenticate.company!.name}",
            "Email: ${authenticate.company!.email}",
            "Currency: ${authenticate.company!.currency!.description}",
            "Employees: ${authenticate.company!.employees.length}",
          ]),
          makeDashboardItem('dbInventory', context, menuOptions[2], [
            "Incoming Shipments: ${authenticate.stats?.incomingShipments ?? 0}",
            "Outgoing Shipments: ${authenticate.stats?.outgoingShipments ?? 0}",
            "Wh Locations: ${authenticate.stats?.whLocations ?? 0}",
          ]),
        ]);
      }
      return const LoadingIndicator();
    });
  }
}
