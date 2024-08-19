import 'package:flutter/material.dart';
import 'package:pullebyte/CustomWidgets/canhotos_holder.dart';
import 'package:pullebyte/CustomWidgets/custom_app_bar.dart';
import 'package:pullebyte/CustomWidgets/canhotos_searchbar.dart';
import 'package:pullebyte/CustomWidgets/guardar_canhotos_button.dart';

class Canhotos extends StatefulWidget {
  const Canhotos({super.key});

  @override
  _CanhotosState createState() => _CanhotosState();
}

class _CanhotosState extends State<Canhotos>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(),
              CanhotosSearchBar(),
              CanhotosHolder(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Positioned(bottom: 16.0, right: 16.0, child: AdicionarCanhotoButton())
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
