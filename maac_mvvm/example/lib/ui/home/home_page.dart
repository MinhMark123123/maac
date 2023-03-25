import 'package:example/navigation/routers.dart';
import 'package:example/ui/home/view_models/home_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm/maac_mvvm.dart';

class MyHomePage extends ViewModelWidget<HomePageViewModel> {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, HomePageViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Builder(builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Hi there:'),
              MaterialButton(
                color: Colors.green,
                onPressed: () {
                  showAboutDialog(context: context);
                },
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(AppRoutes.home + AppRoutes.second);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  HomePageViewModel createViewModel() => HomePageViewModel();
}
