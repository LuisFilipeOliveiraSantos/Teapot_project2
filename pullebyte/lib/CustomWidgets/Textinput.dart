import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pullebyte/theme/colors.dart';
import 'package:intl/intl.dart'; 

class TextFieldSample extends StatelessWidget {
  final String hintText;
  final bool isSenha;
  final bool? isDate;
  final bool? isValue;
  final bool? isTime;
  final double? inputWidth;
  final bool? isMoney;
  final Function(String value)? onChanged;
  final TextEditingController controller;

  const TextFieldSample({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isSenha,
    this.isDate = false,
    this.isValue = false,
    this.isTime = false,
    this.inputWidth = 0.85,
    this.isMoney = false,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth * inputWidth!;
    return Theme(
      data: ThemeData(
        colorScheme: customColorScheme,
      ),
      child: SizedBox(
        width: width,
        child: isDate == true
            ? InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((selectedDate) {
                    if (selectedDate != null) {
                      controller.text = DateFormat('dd/MM/yyyy').format(selectedDate);
                    }
                  });
                },
                child: IgnorePointer(
                  child: TextField(
                    controller: controller,
                    cursorRadius: const Radius.circular(8),
                    style: const TextStyle(color: CustomColors.accentColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomColors.textFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: CustomColors.textFieldColor,
                        ),
                      ),
                      hintText: hintText,
                      hintStyle: const TextStyle(color: CustomColors.accentColor),
                      labelStyle: const TextStyle(color: CustomColors.accentColor),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  ),
                ),
              )
            : isValue == true
                ? TextField(
                    controller: controller,
                    cursorRadius: const Radius.circular(8),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: const TextStyle(color: CustomColors.accentColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomColors.textFieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: CustomColors.textFieldColor,
                        ),
                      ),
                      hintText: isMoney == true ? '10.00' : hintText,
                      prefixText: isMoney == true ? 'R\$ ' : null,
                      prefixStyle: isMoney == true ? const TextStyle(color: CustomColors.accentColor, fontSize: 16) : null,
                      hintStyle: const TextStyle(color: CustomColors.accentColor),
                      labelText: isMoney == true ? hintText : null,
                      labelStyle: const TextStyle(color: CustomColors.accentColor),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                  )
                : isTime == true
                    ? TextField(
                        controller: controller,
                        cursorRadius: const Radius.circular(8),
                        keyboardType: TextInputType.datetime,
                        style: const TextStyle(color: CustomColors.accentColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: CustomColors.textFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: CustomColors.textFieldColor,
                            ),
                          ),
                          hintText: hintText,
                          hintStyle: const TextStyle(color: CustomColors.accentColor),
                          labelStyle: const TextStyle(color: CustomColors.accentColor),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      )
                    : TextField(
                        controller: controller,
                        onChanged: onChanged,
                        cursorRadius: const Radius.circular(8),
                        obscureText: isSenha,
                        style: const TextStyle(color: CustomColors.accentColor),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: CustomColors.textFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: CustomColors.textFieldColor,
                            ),
                          ),
                          hintText: hintText,
                          hintStyle: const TextStyle(color: CustomColors.accentColor),
                          labelStyle: const TextStyle(color: CustomColors.accentColor),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
      ),
    );
  }
}
