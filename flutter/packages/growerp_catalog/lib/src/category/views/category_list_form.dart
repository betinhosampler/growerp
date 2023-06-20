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
import 'package:growerp_core/growerp_core.dart';
import '../category.dart';

class CategoryListForm extends StatelessWidget {
  const CategoryListForm({super.key});

  @override
  Widget build(BuildContext context) => RepositoryProvider(
      create: (context) => CatalogAPIRepository(
          context.read<AuthBloc>().state.authenticate!.apiKey!),
      child: BlocProvider<CategoryBloc>(
          create: (BuildContext context) => CategoryBloc(CatalogAPIRepository(
              context.read<AuthBloc>().state.authenticate!.apiKey!))
            ..add(const CategoryFetch()),
          child: const CategoryList()));
}

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  CategoriesListState createState() => CategoriesListState();
}

class CategoriesListState extends State<CategoryList> {
  final _scrollController = ScrollController();
  late bool search;
  late CategoryBloc _categoryBloc;
  late CatalogAPIRepository _repos;
  late bool started;

  @override
  void initState() {
    super.initState();
    started = false;
    search = false;
    _categoryBloc = context.read<CategoryBloc>();
    _repos = context.read<CatalogAPIRepository>();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
        listenWhen: (previous, current) =>
            previous.status == CategoryStatus.loading,
        listener: (context, state) {
          if (state.status == CategoryStatus.failure) {
            HelperFunctions.showMessage(
                context, '${state.message}', Colors.red);
          }
          if (state.status == CategoryStatus.success) {
            started = true;
            HelperFunctions.showMessage(
                context, '${state.message}', Colors.green);
          }
        },
        builder: (context, state) {
          return Stack(children: [
            Scaffold(
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                      heroTag: 'catFiles',
                      key: const Key("upDownload"),
                      onPressed: () async {
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) =>
                                RepositoryProvider.value(
                                    value: _repos,
                                    child: BlocProvider.value(
                                        value: _categoryBloc,
                                        child: const CategoryFilesDialog())));
                      },
                      tooltip: 'category up/download',
                      child: const Icon(Icons.file_copy)),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                      heroTag: 'catNew',
                      key: const Key("addNew"),
                      onPressed: () async {
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return BlocProvider.value(
                                  value: _categoryBloc,
                                  child: CategoryDialog(Category()));
                            });
                      },
                      tooltip: 'Add New',
                      child: const Icon(Icons.add)),
                ]),
                body: RefreshIndicator(
                    onRefresh: (() async => context
                        .read<CategoryBloc>()
                        .add(const CategoryFetch(refresh: true))),
                    child: ListView.builder(
                      key: const Key('listView'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.hasReachedMax
                          ? state.categories.length + 1
                          : state.categories.length + 2,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Column(children: [
                            const CategoryListHeader(),
                            Visibility(
                                visible: state.categories.isEmpty,
                                child: Center(
                                    heightFactor: 20,
                                    child: Text(
                                        started ? 'No categories found' : '',
                                        key: const Key('empty'),
                                        textAlign: TextAlign.center)))
                          ]);
                        }
                        index--;
                        return index >= state.categories.length
                            ? const BottomLoader()
                            : Dismissible(
                                key: const Key('categoryItem'),
                                direction: DismissDirection.startToEnd,
                                child: CategoryListItem(
                                    category: state.categories[index],
                                    index: index));
                      },
                    ))),
            if (state.status == CategoryStatus.updateLoading)
              const LoadingIndicator(),
          ]);
        });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<CategoryBloc>().add(const CategoryFetch());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
