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
import '../../../domains/tasks/bloc/task_bloc.dart';

class TaskListHeader extends StatefulWidget {
  const TaskListHeader({Key? key}) : super(key: key);

  @override
  State<TaskListHeader> createState() => _TaskListHeaderState();
}

class _TaskListHeaderState extends State<TaskListHeader> {
  String searchString = '';
  bool search = false;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: (() => setState(() => search ? search = false : search = true)),
        leading: const Icon(Icons.search_sharp, size: 40),
        title: search
            ? Row(children: <Widget>[
                SizedBox(
                    width: ResponsiveBreakpoints.of(context).isMobile
                        ? MediaQuery.of(context).size.width - 250
                        : MediaQuery.of(context).size.width - 350,
                    child: TextField(
                      textInputAction: TextInputAction.go,
                      autofocus: true,
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        hintText: "search in name and description...",
                      ),
                      onChanged: ((value) =>
                          setState(() => searchString = value)),
                    )),
                ElevatedButton(
                    child: const Text('Search'),
                    onPressed: () {
                      context
                          .read<TaskBloc>()
                          .add(TaskFetch(searchString: searchString));
                    })
              ])
            : Column(children: [
                Row(children: <Widget>[
                  const Expanded(child: Text("Name")),
                  const Expanded(child: Text("Status")),
                  const Text("Hours"),
                  if (!ResponsiveBreakpoints.of(context).isMobile)
                    const Expanded(
                        child:
                            Text("From/To Party", textAlign: TextAlign.center)),
                ]),
                const Divider(),
              ]),
        trailing: search ? null : const SizedBox(width: 20));
  }
}
