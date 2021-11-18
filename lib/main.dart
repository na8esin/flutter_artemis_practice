import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:artemis/artemis.dart';

import 'graphql/big_query.dart';

void main() {
  runApp(const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: MyBody(),
      ),
    ),
  ));
}

final bigQueryProvider = FutureProvider((ref) async {
  final client = ArtemisClient(
    'https://graphql-pokemon2.vercel.app',
  );
  final bigQuery = BigQueryQuery(variables: BigQueryArguments(quantity: 6));

  final bigQueryResponse = await client.execute(bigQuery);

  ref.onDispose(() {
    client.dispose();
  });

  return bigQueryResponse.data?.pokemons;
});

class MyBody extends HookConsumerWidget {
  const MyBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPokemons = ref.watch(bigQueryProvider);
    return GridView.count(
        crossAxisCount: 2,
        children: asyncPokemons.when(
            data: (pokemons) {
              if (pokemons == null || pokemons.isEmpty) {
                return [const SizedBox.shrink()];
              } else {
                return pokemons
                    .map((e) => SizedBox(
                          width: 300.0,
                          height: 150.0,
                          child: Center(
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              imageUrl: e!.image!,
                            ),
                          ),
                        ))
                    .toList();
              }
            },
            error: (e, s) => [Text(e.toString())],
            loading: () => [const CircularProgressIndicator()]));
  }
}
