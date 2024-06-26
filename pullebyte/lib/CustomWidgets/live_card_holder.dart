import 'package:flutter/material.dart';
import 'package:pullebyte/CustomWidgets/live_card.dart';

class CardHolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Ao Vivo",
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8), 
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    50,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: LiveCard(),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
