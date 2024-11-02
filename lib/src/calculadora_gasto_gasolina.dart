// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalcGastoGasolinaDemo extends StatefulWidget {
  const CalcGastoGasolinaDemo({super.key});

  @override
  State<CalcGastoGasolinaDemo> createState() => _CalcGastoGasolinaDemoState();
}

class _CalcGastoGasolinaDemoState extends State<CalcGastoGasolinaDemo> {
  final _formKey = GlobalKey<FormState>();

  int mediaKmPorLitro = 0;
  int kmRodados = 0;
  double precoGasolina = 0.0;
  var precoGasolinaController = TextEditingController();

  double calculaGasto() {
    return kmRodados / mediaKmPorLitro * precoGasolina;
  }

  var formatarMonetario = NumberFormat("R\$ ###.00", "pt_BR");

  Future<void> _carregarPrecoGasolinaSalva() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      precoGasolina = prefs.getDouble('precoGasolina') ?? 0.0;
      precoGasolinaController.text =
          precoGasolina.toString().replaceAll('.', ',');
    });
  }

  Future<void> _salvarPrecoGasolina(double preco) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('precoGasolina', preco);
  }

  @override
  Widget build(BuildContext context) {
    if (precoGasolina == 0.0) {
      _carregarPrecoGasolinaSalva();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 Calculadora de Gasto de Gasolina'),
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
                    hintText: '15',
                    labelText: 'Media da Km/l',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    mediaKmPorLitro = int.parse(value);
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
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
                    hintText: '30',
                    labelText: 'Kilometros rodados',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    kmRodados = int.parse(value);
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
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
                    labelText: 'Preço da Gasolina',
                  ),
                  controller: precoGasolinaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\,?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    if (value.isEmpty) {
                      return;
                    }

                    precoGasolina = double.parse(value.replaceAll(',', '.'));
                    _salvarPrecoGasolina(precoGasolina);
                  },
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

                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Seu gasto foi de:'),
                          content:
                              Text(formatarMonetario.format(calculaGasto())),
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
                    },
                    child: Text('Calcular')),
                const SizedBox(
                  height: 24,
                ),
                // A text field that validates that the text is an adjective.
                // TextFormField(
                //   autofocus: false,
                //   textInputAction: TextInputAction.next,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter an adjective.';
                //     }
                //     if (english_words.adjectives.contains(value)) {
                //       return null;
                //     }
                //     return 'Not a valid adjective.';
                //   },
                //   decoration: const InputDecoration(
                //     filled: true,
                //     hintText: 'e.g. quick, beautiful, interesting',
                //     labelText: 'Enter an adjective',
                //   ),
                //   onChanged: (value) {
                //     adjective = value;
                //   },
                // ),
                // const SizedBox(
                //   height: 24,
                // ),
                // // A text field that validates that the text is a noun.
                // TextFormField(
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter a noun.';
                //     }
                //     if (english_words.nouns.contains(value)) {
                //       return null;
                //     }
                //     return 'Not a valid noun.';
                //   },
                //   decoration: const InputDecoration(
                //     filled: true,
                //     hintText: 'i.e. a person, place or thing',
                //     labelText: 'Enter a noun',
                //   ),
                //   onChanged: (value) {
                //     noun = value;
                //   },
                // ),
                // const SizedBox(
                //   height: 24,
                // ),
                // A custom form field that requires the user to check a
                // checkbox.
                // FormField<bool>(
                //   initialValue: false,
                //   validator: (value) {
                //     if (value == false) {
                //       return 'You must agree to the terms of service.';
                //     }
                //     return null;
                //   },
                //   builder: (formFieldState) {
                //     return Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Checkbox(
                //               value: agreedToTerms,
                //               onChanged: (value) {
                //                 // When the value of the checkbox changes,
                //                 // update the FormFieldState so the form is
                //                 // re-validated.
                //                 formFieldState.didChange(value);
                //                 setState(() {
                //                   agreedToTerms = value;
                //                 });
                //               },
                //             ),
                //             Text(
                //               'I agree to the terms of service.',
                //               style: Theme.of(context).textTheme.titleMedium,
                //             ),
                //           ],
                //         ),
                //         if (!formFieldState.isValid)
                //           Text(
                //             formFieldState.errorText ?? "",
                //             style: Theme.of(context)
                //                 .textTheme
                //                 .bodySmall!
                //                 .copyWith(
                //                     color: Theme.of(context).colorScheme.error),
                //           ),
                //       ],
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
