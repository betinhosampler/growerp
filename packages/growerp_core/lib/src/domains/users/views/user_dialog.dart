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

import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import '../../common/functions/helper_functions.dart';
import '../../../services/api_result.dart';
import '../../../templates/templates.dart';
import '../../domains.dart';
import '../../../api_repository.dart';

final GlobalKey<ScaffoldMessengerState> userDialogKey =
    GlobalKey<ScaffoldMessengerState>();

/// User dialog with a required User class input containing the role
class UserDialog extends StatelessWidget {
  final User user;
  const UserDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserPage(user);
  }
}

class UserPage extends StatefulWidget {
  final User user;
  const UserPage(this.user, {super.key});
  @override
  UserDialogState createState() => UserDialogState();
}

class UserDialogState extends State<UserPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _companySearchBoxController = TextEditingController();

  bool loading = false;
  late List<UserGroup> localUserGroups;
  late UserGroup _selectedUserGroup;
  late Role _selectedRole;
  Company? _selectedCompany;
  XFile? _imageFile;
  dynamic _pickImageError;
  String? _retrieveDataError;
  late User updatedUser;
  late APIRepository repos;
  final ImagePicker _picker = ImagePicker();

  late bool isPhone;

  @override
  void initState() {
    super.initState();
    if (widget.user.partyId != null) {
      _firstNameController.text = widget.user.firstName ?? '';
      _lastNameController.text = widget.user.lastName ?? '';
      _nameController.text = widget.user.loginName ?? '';
      _telephoneController.text = widget.user.telephoneNr ?? '';
      _emailController.text = widget.user.email ?? '';
      _selectedCompany = Company(
          partyId: widget.user.company!.partyId,
          name: widget.user.company!.name);
    }
    _selectedUserGroup = widget.user.userGroup ?? UserGroup.employee;
    _selectedRole = widget.user.company!.role!;
    localUserGroups = UserGroup.values;
    updatedUser = widget.user;
  }

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    isPhone = ResponsiveWrapper.of(context).isSmallerThan(TABLET);
    repos = context.read<APIRepository>();
    User? user = widget.user;
    return BlocConsumer<UserBloc, UserState>(listener: (context, state) {
      if (state.status == UserStatus.failure) {
        loading = false;
        userDialogKey.currentState!
            .showSnackBar(snackBar(context, Colors.red, state.message ?? ''));
      }
      if (state.status == UserStatus.success) {
        Navigator.of(context).pop(updatedUser);
      }
    }, builder: (context, state) {
      return Stack(children: [
        scaffoldWidget(user, context),
        if (state.status == UserStatus.loading) const LoadingIndicator(),
      ]);
    });
  }

  Dialog scaffoldWidget(User user, BuildContext context) {
    return Dialog(
      key: Key('UserDialog${user.userGroup.toString()}'),
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: popUp(
          context: context,
          title: 'User information',
          width: isPhone ? 400 : 1000,
          height: isPhone ? 1020 : 700,
          child: ScaffoldMessenger(
              key: userDialogKey,
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton:
                      imageButtons(context, _onImageButtonPressed),
                  body: listChild()))),
    );
  }

  Widget listChild() {
    return Builder(builder: (BuildContext context) {
      return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? FutureBuilder<void>(
              future: retrieveLostData(),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Pick image error: ${snapshot.error}}',
                    textAlign: TextAlign.center,
                  );
                }
                return _showForm();
              })
          : _showForm();
    });
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _showForm() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    }
    return _userDialog();
  }

  Widget _userDialog() {
    Authenticate authenticate = context.read<AuthBloc>().state.authenticate!;
    User? currentUser = authenticate.user;
    if (widget.user.userGroup == UserGroup.admin ||
        widget.user.userGroup == UserGroup.employee) {
      _selectedCompany = authenticate.company;
    }

    Future<List<Company>> getOwnedCompanies(filter) async {
      ApiResult<List<Company>> result = await repos.getCompanies(
          filter: _companySearchBoxController.text, mainCompanies: false);
      return result.when(
          success: (data) => data,
          failure: (_) => [Company(name: 'get data error!')]);
    }

    List<Widget> widgets = [
      InputDecorator(
        decoration: InputDecoration(
          labelText: 'User information',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: TextFormField(
                key: const Key('firstName'),
                decoration: const InputDecoration(labelText: 'First Name'),
                controller: _firstNameController,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a first name?';
                  return null;
                },
              )),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: const Key('lastName'),
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  controller: _lastNameController,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a last name?';
                    return null;
                  },
                ),
              )
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('email'),
                    decoration:
                        const InputDecoration(labelText: 'Email address'),
                    controller: _emailController,
                    validator: (String? value) {
                      if (value!.isEmpty) return 'Please enter Email address?';
                      if (!RegExp(
                              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(value)) {
                        return 'This is not a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: const Key('telephoneNr'),
                    decoration:
                        const InputDecoration(labelText: 'Telephone number'),
                    controller: _telephoneController,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Visibility(
          visible: updatedUser.company!.role != Role.employee,
          child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Company information',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: Column(children: [
                Row(children: [
                  Expanded(
                    child: DropdownSearch<Company>(
                      key: const Key('companyName'),
                      selectedItem: _selectedCompany,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                          ),
                          controller: _companySearchBoxController,
                        ),
                        menuProps: MenuProps(
                            borderRadius: BorderRadius.circular(20.0)),
                        title: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                )),
                            child: const Center(
                                child: Text('Select company',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )))),
                      ),
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Existing Company',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                      ),
                      itemAsString: (Company? u) => "${u!.name}",
                      asyncItems: (String? filter) =>
                          getOwnedCompanies(_companySearchBoxController.text),
                      onChanged: (Company? newValue) {
                        setState(() {
                          _selectedCompany = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null && _companyController.text == ''
                              ? "Select an existing or Create a new company"
                              : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextFormField(
                    key: const Key('newCompanyName'),
                    decoration:
                        const InputDecoration(labelText: 'New Company Name'),
                    controller: _companyController,
                    validator: (value) {
                      if (value!.isEmpty && _selectedCompany == null) {
                        return 'Please enter an existing or new company?';
                      }
                      return null;
                    },
                  )),
                ]),
                const SizedBox(height: 10),
                DropdownButtonFormField<Role>(
                  key: const Key('role'),
                  decoration: const InputDecoration(labelText: 'Role'),
                  hint: const Text('Role'),
                  value: _selectedRole,
                  validator: (value) =>
                      value == null ? 'Role field required!' : null,
                  items: Role.values.map((item) {
                    return DropdownMenuItem<Role>(
                        value: item, child: Text(item.value));
                  }).toList(),
                  onChanged: (Role? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  isExpanded: true,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: Text(
                          updatedUser.company!.address != null
                              ? "${updatedUser.company!.address!.city!} "
                                  "${updatedUser.company!.address!.country!}"
                              : "No address yet",
                          key: const Key('addressLabel'))),
                  Expanded(
                      child: ElevatedButton(
                    key: const Key('address'),
                    onPressed: () async {
                      var result = await showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return AddressDialog(
                                address: updatedUser.company!.address);
                          });
                      if (!mounted) return;
                      if (result is Address) {
                        context.read<UserBloc>().add(UserUpdate(
                            updatedUser.copyWith(
                                company: updatedUser.company!
                                    .copyWith(address: result))));
                      }
                    },
                    child: Text(
                        "${updatedUser.company!.address != null ? 'Update' : 'Add'}"
                        " postal address"),
                  ))
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: Text(
                          updatedUser.company!.paymentMethod != null
                              ? "${updatedUser.company!.paymentMethod?.ccDescription}"
                              : "No payment methods yet",
                          key: const Key('paymentMethodLabel'))),
                  Expanded(
                    child: SizedBox(
                        width: 100,
                        child: ElevatedButton(
                            key: const Key('paymentMethod'),
                            onPressed: updatedUser.company!.address == null
                                ? null
                                : () async {
                                    var result = await showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PaymentMethodDialog(
                                              paymentMethod: updatedUser
                                                  .company!.paymentMethod);
                                        });
                                    if (!mounted) return;
                                    if (result is PaymentMethod) {
                                      context.read<UserBloc>().add(UserUpdate(
                                          updatedUser.copyWith(
                                              company: updatedUser.company!
                                                  .copyWith(
                                                      paymentMethod: result))));
                                    }
                                  },
                            child: Text(
                                '${updatedUser.company!.paymentMethod != null ? 'Update' : 'Add'} Payment Method'))),
                  )
                ]),
              ]))),
      InputDecorator(
        decoration: InputDecoration(
          labelText: 'User Login',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Column(
          children: [
            TextFormField(
              key: const Key('loginName'),
              decoration: const InputDecoration(labelText: 'User Login Name '),
              controller: _nameController,
              validator: (value) {
                if (widget.user.userGroup == UserGroup.admin &&
                    value!.isEmpty) {
                  return 'An administrator needs a username!';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Visibility(
                // use only to modify by admin user
                visible: updatedUser.partyId != null &&
                    currentUser!.userGroup == UserGroup.admin,
                child: DropdownButtonFormField<UserGroup>(
                  decoration: const InputDecoration(labelText: 'User Group'),
                  key: const Key('userGroup'),
                  hint: const Text('User Group'),
                  value: _selectedUserGroup,
                  validator: (value) => value == null ? 'field required' : null,
                  items: localUserGroups.map((item) {
                    return DropdownMenuItem<UserGroup>(
                        value: item, child: Text(item.toString()));
                  }).toList(),
                  onChanged: (UserGroup? newValue) {
                    setState(() {
                      _selectedUserGroup = newValue!;
                    });
                  },
                  isExpanded: true,
                )),
          ],
        ),
      ),
    ];
    Widget update = Row(children: [
      ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red)),
          key: const Key('deleteUser'),
          child: const Text('Delete User'),
          onPressed: () async {
            var result =
                await confirmDeleteUserComp(context, widget.user.userGroup!);
            if (result != null) {
              if (!mounted) return;
              // delete company too?
              if (widget.user.partyId == authenticate.user!.partyId!) {
                context.read<AuthBloc>().add(
                    AuthDeleteUser(widget.user.copyWith(image: null), result));
                Navigator.of(context).pop(updatedUser);
                context.read<AuthBloc>().add(const AuthLoggedOut());
              } else {
                context
                    .read<UserBloc>()
                    .add(UserDelete(widget.user.copyWith(image: null)));
              }
            }
          }),
      const SizedBox(width: 10),
      Expanded(
          child: ElevatedButton(
              key: const Key('updateUser'),
              child: Text(updatedUser.partyId == null ? 'Create' : 'Update'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  updatedUser = updatedUser.copyWith(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      email: _emailController.text,
                      loginName: _nameController.text,
                      telephoneNr: _telephoneController.text,
                      userGroup: _selectedUserGroup,
                      language: Localizations.localeOf(context)
                          .languageCode
                          .toString(),
                      company: Company(
                          name: _companyController.text,
                          // if new company name not empty partyId
                          partyId: _companyController.text.isEmpty
                              ? updatedUser.company!.partyId
                              : ''),
                      image: await HelperFunctions.getResizedImage(
                          _imageFile?.path));
                  if (!mounted) return;
                  if (_imageFile?.path != null && updatedUser.image == null) {
                    HelperFunctions.showMessage(
                        context, "Image upload error!", Colors.red);
                  } else {
                    context.read<UserBloc>().add(UserUpdate(updatedUser));
                    if (context
                            .read<AuthBloc>()
                            .state
                            .authenticate!
                            .user!
                            .partyId ==
                        updatedUser.partyId) {
                      context.read<AuthBloc>().add(AuthUserUpdate(updatedUser));
                    }
                  }
                }
              }))
    ]);

    List<Widget> column = [];
    for (var i = 0; i < widgets.length; i++) {
      column.add(Padding(padding: const EdgeInsets.all(10), child: widgets[i]));
    }
    column.add(update);

    List<Widget> rows = [];
    if (!ResponsiveWrapper.of(context).isSmallerThan(TABLET)) {
      rows.add(const SizedBox(height: 20));
      rows.add(Container(
          color: Colors.white,
          height: 350,
          child: MasonryGridView.count(
            itemCount: widgets.length,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemBuilder: (context, index) {
              return widgets[index];
            },
          )));
      rows.add(update);
    }

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            key: const Key('listView'),
            child: Column(children: <Widget>[
              Center(
                  child: Text(
                'User ${widget.user.company!.role.toString()}'
                ' #${updatedUser.partyId ?? " New"}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                key: const Key('header'),
              )),
              Center(
                  child: Text(
                'Company #${updatedUser.company!.partyId ?? ""}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                key: const Key('compHeader'),
              )),
              const SizedBox(height: 10),
              CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 80,
                  child: _imageFile != null
                      ? kIsWeb
                          ? Image.network(_imageFile!.path, scale: 0.3)
                          : Image.file(File(_imageFile!.path), scale: 0.3)
                      : widget.user.image != null
                          ? Image.memory(widget.user.image!, scale: 0.3)
                          : Text(widget.user.firstName?.substring(0, 1) ?? '',
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.black))),
              Column(children: rows.isNotEmpty ? rows : column),
            ])));
  }
}
