import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../managers/data/data_manager.dart';
import '../models/prompt.dart';
import '../ui/custom_scaffold.dart';
import 'home_screen.dart';

class PromptMarket extends StatefulWidget {
  const PromptMarket({super.key});

  @override
  State<PromptMarket> createState() => _PromptMarketState();
}

class _PromptMarketState extends State<PromptMarket> {
  final PagingController<int, Prompt> pagingController =
      PagingController(firstPageKey: 0);

  int pageSize = 20;

  @override
  void initState() {
    pagingController.addPageRequestListener(_fetchPage);

    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await DataManager.instance.fetchMarket(pageKey, pageSize);
      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: 'Prompt Market',
        icon: Icons.arrow_back,
        onTap: () {
          context.go('/home', extra: {'from': '/prompt-market'});
        },
      ),
      body: PagedListView<int, Prompt>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Prompt>(
          itemBuilder: (context, item, index) => GPTCard(
            prompt: item,
          ),
        ),
      ),
    );
  }
}
