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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:growerp_core/growerp_core.dart';

class LocationDialog extends StatefulWidget {
  final Location location;
  const LocationDialog(this.location, {super.key});
  @override
  LocationDialogState createState() => LocationDialogState();
}

class LocationDialogState extends State<LocationDialog> {
  late Location location;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    location = widget.location;
    _nameController.text = location.locationName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = ResponsiveBreakpoints.of(context).isMobile;
    var repos = context.read<APIRepository>();
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Dialog(
            key: const Key('LocationDialog'),
            insetPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: BlocListener<LocationBloc, LocationState>(
                listener: (context, state) async {
                  switch (state.status) {
                    case LocationStatus.success:
                      HelperFunctions.showMessage(
                          context,
                          '${location.locationId == null ? "Add" : "Update"} successfull',
                          Colors.green);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      break;
                    case LocationStatus.failure:
                      HelperFunctions.showMessage(
                          context, 'Error: ${state.message}', Colors.red);
                      break;
                    default:
                      const Text("????");
                  }
                },
                child: popUp(
                    context: context,
                    child: _showForm(repos, isPhone),
                    title:
                        'Location Information #${location.locationId ?? "New"}',
                    height: 200,
                    width: 400))));
  }

  Widget _showForm(repos, isPhone) {
    return Center(
        child: Form(
            key: _formKey,
            child: ListView(key: const Key('listView'), children: <Widget>[
              TextFormField(
                key: const Key('name'),
                decoration: const InputDecoration(labelText: 'Location Name'),
                controller: _nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a location name?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  key: const Key('update'),
                  child:
                      Text(location.locationId == null ? 'Create' : 'Update'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      context.read<LocationBloc>().add(LocationUpdate(
                            Location(
                              locationId: location.locationId,
                              locationName: _nameController.text,
                            ),
                          ));
                    }
                  }),
            ])));
  }
}
