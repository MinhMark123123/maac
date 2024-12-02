import 'package:example/global.dart';
import 'package:example/navigation/routers.dart';
import 'package:example/ui/home/presentation/home_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_riverpod/maac_mvvm_with_riverpod.dart';

class MyHomePage extends ConsumerViewModelWidget<HomePageViewModel> {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget buildWidget(BuildContext context, WidgetRef ref, HomePageViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hi there:'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(navigationProvider).go(AppRoutes.home + AppRoutes.second);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  AutoDisposeProvider<HomePageViewModel> viewModelProvider() => homePageViewModelProvider;
}
