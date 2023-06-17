import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../managers/data/data_manager.dart';
import '../../models/prompt.dart';
import '../../ui/custom_scaffold.dart';
import '../../ui/firestore_query_builder.dart';
import '../../ui/theme_extensions.dart';
import '../home_screen.dart';

class PromptMarket extends StatefulWidget {
  const PromptMarket({super.key});

  @override
  State<PromptMarket> createState() => _PromptMarketState();
}

class _PromptMarketState extends State<PromptMarket> {
  int pageSize = 20;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      // backgroundColor: context.colorScheme.surface,
      title: Text(
        'Prompt Market',
        style: context.textTheme.titleMedium?.copyWith(
          color: context.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: ScaffoldAction(
        tooltip: 'Home',
        icon: Icons.arrow_back,
        onTap: () {
          context.go('/home', extra: {'from': '/prompt-market'});
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FirestoreQueryBuilder<Prompt>(
            query: (int limit) => DataManager.instance.fetchMarket(0, limit),
            builder: (
              context,
              FirestoreQueryBuilderSnapshot<Prompt> item,
              Widget? child,
            ) {
              return ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: item.docs.length,
                clipBehavior: Clip.none,
                itemBuilder: (BuildContext context, int index) {
                  final prompt = item.docs[index];
                  return GPTPromptTile(
                    prompt: prompt,
                    onTap: () {
                      context.go(
                        '/prompt-market/${prompt.id}',
                        extra: {'from': '/prompt-market'},
                      );
                    },
                  )
                      .animate(delay: (50 * index).ms)
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutBack)
                      .moveY(
                          begin: 100,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutBack);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
