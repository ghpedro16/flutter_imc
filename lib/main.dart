import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        home: Home(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          hintColor: Colors.green, // Cor das dicas e rótulos
          primarySwatch: Colors.green, // Cor primária para AppBar
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green, width: 1.0),
            ),
          ),
        ),
      ),
    );

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _result = 'Informe seus dados';

  @override
  void initState() {
    super.initState();
    resetFields();
  }

  // --- Funções Auxiliares ---

  void resetFields() {
    _weightController.text = '';
    _heightController.text = '';
    setState(() {
      _result = 'Informe seus dados';
      // Reinicia a chave do formulário para limpar estados de erro
      _formKey = GlobalKey<FormState>();
    });
  }

  void _calculateImc() {
    // 1. Valida se os campos foram preenchidos
    if (!_formKey.currentState!.validate()) {
      // Se não for válido, não faz nada
      return;
    }

    try {
      // 2. Converte as entradas de forma segura
      double? weight = double.tryParse(_weightController.text);
      double? height = double.tryParse(_heightController.text);

      // 3. Verifica se as conversões foram bem-sucedidas e se a altura é válida (não zero)
      if (weight == null || height == null || height <= 0) {
        setState(() {
          _result = 'Erro: Valores inválidos fornecidos.';
        });
        return;
      }

      // Converte cm para metros
      double heightInMeters = height / 100.0;

      // 4. Calcula o IMC
      double imc = weight / (heightInMeters * heightInMeters);

      setState(() {
        // CORREÇÃO APLICADA AQUI: Reseta _result e atribui o novo valor completo.
        _result = 'IMC: ${imc.toStringAsFixed(2)}\n';

        // 5. Classificação do IMC (usa .toStringAsFixed(2) para 2 casas decimais)
        if (imc < 18.6) {
          _result += 'Abaixo do Peso';
        } else if (imc >= 18.6 && imc < 24.9) {
          _result += 'Peso Ideal';
        } else if (imc >= 24.9 && imc < 29.9) {
          _result += 'Levemente Acima do Peso';
        } else if (imc >= 29.9 && imc < 34.9) {
          _result += 'Obesidade Grau I';
        } else if (imc >= 34.9 && imc < 39.9) {
          _result += 'Obesidade Grau II (Severa)';
        } else {
          _result += 'Obesidade Grau III (Mórbida)';
        }
      });
    } catch (e) {
      // Em caso de erro de parsing ou cálculo (embora o validator já devesse pegar a maioria)
      setState(() {
        _result = 'Erro no cálculo. Tente novamente.';
      });
    }
  }

  // --- Widget para o campo de texto ---

  TextFormField buildTextFormField(
      {TextEditingController? controller, String? error, String? label}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        // Usa o tema definido no MaterialApp, mas pode ser customizado
        labelStyle: TextStyle(fontSize: 20.0),
      ),
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.green, fontSize: 25.0),
      controller: controller,
      // Validador que verifica se o campo está vazio
      validator: (text) {
        if (text == null || text.isEmpty) {
          return error;
        }
        // Validação extra para garantir que é um número válido
        if (double.tryParse(text) == null) {
          return 'Insira um valor numérico válido.';
        }
        return null;
      },
    );
  }

  // --- Método Build (Interface do Usuário) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
        centerTitle: true,
        // Usando primaryColor do Theme
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetFields,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.person_outline, size: 120.0, color: Colors.green),

              // Campo Peso
              buildTextFormField(
                  controller: _weightController,
                  label: 'Peso (Kg)',
                  error: 'Insira seu peso!'),

              SizedBox(height: 20.0), // Espaçamento

              // Campo Altura
              buildTextFormField(
                  controller: _heightController,
                  label: 'Altura (cm)',
                  error: 'Insira sua altura!'),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: SizedBox(
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: _calculateImc,
                    child: Text(
                      'Calcular',
                      style: TextStyle(color: Colors.green, fontSize: 25.0),
                    ),
                    // Usando primaryColor do Theme
                  ),
                ),
              ),

              // Resultado do IMC
              Text(
                _result,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
