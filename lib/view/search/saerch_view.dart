import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:open_labs/components/appButton.dart';
import 'package:open_labs/components/loading.dart';
import 'package:open_labs/core/helpers/bottom_sheet_helper.dart';
import 'saerch_bloc.dart';

class SearchView extends StatefulWidget {
  final ISearchBloc bloc;
  const SearchView(
    this.bloc, {
    super.key,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _userController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.bloc.loadingHistory();
  }

  @override
  void dispose() {
    super.dispose();
    _userController.dispose();
    _focusNode.dispose();
    widget.bloc.dispose();
    log("Dispose Example");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            controller: _userController,
            focusNode: _focusNode,
            autofocus: true,
            showCursor: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _focusNode.unfocus();
              widget.bloc.navigatorPopGetUserName(_userController.text);
            },
            decoration: InputDecoration(
              alignLabelWithHint: false,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _focusNode.unfocus();
                  widget.bloc.navigatorPopGetUserName(_userController.text);
                },
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<SearchModelBloc>(
              stream: widget.bloc.onFetchingData,
              initialData: SearchModelBloc("Initial state", isLoading: false),
              builder: (context, snapshot) {
                if (!snapshot.hasError) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isLoading) {
                      return Center(
                        child: AnimatedLoading(title: snapshot.data!.state),
                      );
                    }
                    if (snapshot.data!.searchHistory != null &&
                        snapshot.data!.searchHistory!.isNotEmpty) {
                      final searchHistory = snapshot.data!.searchHistory!;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Historico de pesquisa",
                            textAlign: TextAlign.start,
                          ),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                              itemCount: searchHistory.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                    title:
                                        Text(searchHistory[index].searchWord),
                                    onTap: () {
                                      widget.bloc.navigatorPopGetUserName(
                                          searchHistory[index].searchWord);
                                    },
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        widget.bloc.deleteHistory(
                                            searchHistory[index].id!);
                                        log('Teste ${searchHistory[index].searchWord}');
                                      },
                                    ));
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  }
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    BottomSheetHelper().bottomSheetCustom(
                        subtitle: snapshot.error.toString(),
                        isDismissible: true,
                        enableDrag: false,
                        context: context,
                        buttons: [
                          AppOutlinedButton(
                            "Voltar",
                            onPressed: () {
                              widget.bloc.navigatorPop();
                              widget.bloc.navigatorPop();
                            },
                          ),
                        ]);
                  });
                }

                return Center(
                  child: Text("Insira o nome do usuário",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                );
              }),
        ));
  }
}
