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
import '../../domains.dart';

Widget popUp({
  required BuildContext context,
  required Widget child,
  String title = '',
  double height = 400,
  double width = 400,
}) {
  return Stack(clipBehavior: Clip.none, children: [
    SizedBox(
        width: width,
        height: height,
        child: Column(children: [
          Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: Center(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)))),
          Expanded(
              child: Padding(padding: const EdgeInsets.all(20), child: child)),
        ])),
    const Positioned(top: 10, right: 10, child: DialogCloseButton())
  ]);
}
