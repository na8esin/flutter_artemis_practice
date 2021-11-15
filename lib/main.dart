import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:artemis/artemis.dart';

import 'graphql/big_query.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: MyBody(),
    ),
  ));
}

final bigQueryProvider = FutureProvider((ref) async {
  final client = ArtemisClient(
    'https://graphql-pokemon2.vercel.app',
  );
  final bigQuery = BigQueryQuery(variables: BigQueryArguments(quantity: 5));

  final bigQueryResponse = await client.execute(bigQuery);

  ref.onDispose(() {
    client.dispose();
  });

  return bigQueryResponse.data?.pokemons;

  for (final pokemon in bigQueryResponse.data?.pokemons ?? []) {
    print('#${pokemon.number}: ${pokemon.name}');
  }
});

class MyBody extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPokemons = ref.watch(bigQueryProvider);
    return ListView(children: [
      asyncPokemons.when(
          data: (pokemons) {
            if (pokemons == null || pokemons.isEmpty) {
              return const SizedBox.shrink();
            } else{
              return pokemons.map((e) => ListTile())
            }
          },
          error: error,
          loading: loading)
    ]);
  }
}
