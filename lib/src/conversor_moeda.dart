// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

final moedasDisponiveis2 = {
  "usd": "Dólar Americano",
  "eur": "Euro",
  "brl": "Real Brasileiro",
  "gbp": "Libra Esterlina",
  "jpy": "Iene Japonês",
  "aud": "Dólar Australiano",
  "cad": "Dólar Canadense",
  "chf": "Franco Suíço",
  "cny": "Yuan Renminbi Chinês",
  "inr": "Rúpia Indiana",
  "rub": "Rublo Russo",
  "krw": "Won Sul-Coreano",
  "mxn": "Peso Mexicano",
  "idr": "Rupia Indonésia",
  "try": "Lira Turca",
  "zar": "Rand Sul-Africano",
  "hkd": "Dólar de Hong Kong",
  "sgd": "Dólar de Singapura",
  "nzd": "Dólar Neozelandês",
  "thb": "Baht Tailandês",
};

class ConvMoedasDemo extends StatefulWidget {
  const ConvMoedasDemo({super.key});

  @override
  State<ConvMoedasDemo> createState() => _ConvMoedasDemoState();
}

class _ConvMoedasDemoState extends State<ConvMoedasDemo> {
  final _formKey = GlobalKey<FormState>();

  double valor = 0.0;
  var valorController = TextEditingController();

  String moeda1 = moedasDisponiveis2.keys.elementAt(0);
  String moeda2 = moedasDisponiveis2.keys.elementAt(2);

  var monetarioInternacional = NumberFormat("##0.00", "pt_BR");

  @override
  Widget build(BuildContext context) {
    Future<void> converterMoeda() async {
      var url = Uri.parse(
          'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/${moeda1.toLowerCase()}.json');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson =
            jsonDecode(response.body) as Map<String, dynamic>;

        var taxas = decodedJson[moeda1.toLowerCase()] as Map<dynamic, dynamic>;

        var taxaComMoeda2 = taxas[moeda2.toLowerCase()] as double;

        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Valor Convertido'),
            content: Text(monetarioInternacional.format(valor * taxaComMoeda2)),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      } else {
        throw Exception('Falha ao carregar taxa de conversão');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Conversor de Moedas'),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor informe o valor.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: '5,20',
                    labelText: 'Valor',
                  ),
                  controller: valorController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\,?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      return;
                    }

                    valor = double.parse(value.replaceAll(',', '.'));
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    Column(children: [
                      Text('Converter de:'),
                      DropdownButton<String>(
                          value: moeda1,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              moeda1 = value!;
                            });
                          },
                          items: moedasDisponiveis2.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(moedasDisponiveis2[value]!),
                            );
                          }).toList()),
                    ]),
                    Column(children: [
                      Text('Para:'),
                      DropdownButton<String>(
                          value: moeda2,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              moeda2 = value!;
                            });
                          },
                          items: moedasDisponiveis2.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(moedasDisponiveis2[value]!),
                            );
                          }).toList()),
                    ]),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                    onPressed: () {
                      var valid = _formKey.currentState!.validate();
                      if (!valid) {
                        return;
                      }

                      converterMoeda();
                    },
                    child: Text('Converter')),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
