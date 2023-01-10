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

import 'package:growerp_core/domains/common/functions/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:growerp_core/domains/domains.dart';
import 'package:growerp_core/api_repository.dart';

import '../website.dart';

class WebsiteCategoryDialog extends StatelessWidget {
  final String websiteId;
  final Category category;
  const WebsiteCategoryDialog(this.websiteId, this.category, {super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ProductBloc(context.read<APIRepository>())..add(const ProductFetch()),
      child: WebsiteCategoryDialogFull(websiteId, category),
    );
  }
}

class WebsiteCategoryDialogFull extends StatefulWidget {
  final String websiteId;
  final Category category;
  const WebsiteCategoryDialogFull(this.websiteId, this.category, {super.key});
  @override
  _CategoryState createState() => _CategoryState(category);
}

class _CategoryState extends State<WebsiteCategoryDialogFull> {
  final Category category;
  final _websiteCatFormKey = GlobalKey<FormState>();
  List<Product> _selectedProducts = [];
  late String classificationId;

  _CategoryState(this.category);

  @override
  void initState() {
    classificationId = GlobalConfiguration().get("classificationId");
    _selectedProducts = List.of(category.products);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebsiteBloc, WebsiteState>(
        listener: (context, state) {
          if (state.status == WebsiteStatus.success) {
            Navigator.of(context).pop();
          }
          if (state.status == WebsiteStatus.failure) {
            HelperFunctions.showMessage(context, state.message, Colors.red);
          }
        },
        child: BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) async {
          switch (state.status) {
            case ProductStatus.failure:
              HelperFunctions.showMessage(context,
                  'Error getting categories: ${state.message}', Colors.red);
              break;
            default:
          }
        }, builder: (context, state) {
          if (state.status == ProductStatus.success) {
            return Dialog(
                key: const Key('WebsiteCategoryDialog'),
                insetPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                    width: 400,
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Stack(clipBehavior: Clip.none, children: [
                          _categoryDialog(state),
                          Positioned(
                              top: 5, right: 5, child: DialogCloseButton()),
                        ]))));
          }
          return LoadingIndicator();
        }));
  }

  Widget _categoryDialog(ProductState state) {
    List<Widget> productsWrap = [];
    _selectedProducts.asMap().forEach((index, product) {
      productsWrap.add(InputChip(
        label: Text(product.productName!, key: Key(product.productName!)),
        deleteIcon:
            Icon(Icons.cancel, key: Key('delete${product.productName!}')),
        onDeleted: () async {
          setState(() {
            _selectedProducts.removeAt(index);
          });
        },
      ));
    });
    productsWrap.add(IconButton(
      iconSize: 30,
      icon: const Icon(Icons.add_circle),
      color: Colors.deepOrange,
      padding: const EdgeInsets.all(0.0),
      key: const Key('addProducts'),
      onPressed: () async {
        var result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return MultiSelect<Product>(
                title: 'Select one or more products',
                items: state.products,
                selectedItems: _selectedProducts,
              );
            });
        if (result != null) {
          setState(() {
            _selectedProducts = result;
          });
        }
      },
    ));

    return Form(
        key: _websiteCatFormKey,
        child: ListView(key: const Key('listView'), children: <Widget>[
          Center(
              child: Text(
            'Category #${category.categoryId.isEmpty ? " New" : category.categoryId}',
            style: const TextStyle(
                fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
            key: const Key('header'),
          )),
          const SizedBox(height: 30),
          Center(
              child: Text(
            "Products in ${category.categoryName}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
          const SizedBox(height: 30),
          Wrap(
            spacing: 10.0,
            children: productsWrap,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              key: const Key('update'),
              child: const Text('Update'),
              onPressed: () async {
                context.read<WebsiteBloc>().add(WebsiteUpdate(Website(
                        id: widget.websiteId,
                        websiteCategories: [
                          widget.category.copyWith(products: _selectedProducts)
                        ])));
              }),
        ]));
  }
}
