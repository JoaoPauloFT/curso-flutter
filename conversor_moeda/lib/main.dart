import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

var url = Uri.https("economia.awesomeapi.com.br", "/json/last/BRL-USD,BRL-EUR");

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? realDolar;
  double? realEuro;

  void _changedReal(String text) {
    dolarController.text = (double.parse(text) * realDolar!).toStringAsFixed(2);
    euroController.text = (double.parse(text) * realEuro!).toStringAsFixed(2);
  }

  void _changedDolar(String text) {
    print("realDolar: ${realDolar}");
    print("realEuro: ${realEuro}");
    realController.text = (double.parse(text) / realDolar!).toStringAsFixed(2);
    euroController.text = (double.parse(realController.text) * realEuro!).toStringAsFixed(2);
  }

  void _changedEuro(String text) {
    realController.text = (double.parse(text) / realEuro!).toStringAsFixed(2);
    dolarController.text = (double.parse(realController.text) * realDolar!).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                realDolar = double.parse(snapshot.data!["BRLUSD"]["bid"]);
                realEuro = double.parse(snapshot.data!["BRLEUR"]["bid"]);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField("Reais", "R\$ ", realController, _changedReal),
                      const Divider(
                        color: Colors.transparent,
                      ),
                      buildTextField("Dólares", "US\$ ", dolarController, _changedDolar),
                      const Divider(
                        color: Colors.transparent,
                      ),
                      buildTextField("Euros", "€ ", euroController, _changedEuro),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function(String) onChange) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    onChanged: onChange,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 20,
    ),
  );
}
