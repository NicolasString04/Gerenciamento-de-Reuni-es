import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';
import 'package:intl/intl.dart'; // Importando para formatação de data

class Registrar extends StatefulWidget {
  @override
  _RegistrarState createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _resumoController = TextEditingController();
  String _horario = '';
  DateTime? _dataSelecionada;  

  //mostrar o calendário personalizado
  Future<void> _mostrarCalendarioPersonalizado(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 400, 
            height: 400, 
            child: CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(), // Impede a seleção de dias anteriores
              lastDate: DateTime(2101),
              onDateChanged: (data) {
                setState(() {
                  _dataSelecionada = data;
                });
                Navigator.of(context).pop(); 
              },
            ),
          ),
        );
      },
    );
  }

  // salvar a reunião
  void _salvarReuniao() {
    if (_nomeController.text.isNotEmpty &&
        _resumoController.text.isNotEmpty &&
        _horario.isNotEmpty &&
        _dataSelecionada != null) {
      _databaseService.addMeeting(
        _nomeController.text,
        _resumoController.text,
        _horario,
        _dataSelecionada!,
      );

      // Limpar campos após salvar
      _nomeController.clear();
      _resumoController.clear();
      setState(() {
        _horario = '';
        _dataSelecionada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reunião salva com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Registrar Reuniões",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFbbcde5),
                Color(0xFFbbcde5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome da Reunião'),
              ),
              TextField(
                controller: _resumoController,
                decoration: InputDecoration(labelText: 'Resumo da Reunião'),
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(labelText: 'Horário: $_horario'),
                onTap: () async {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat:
                                true), // Usa formato 24 horas, assim ficara no padrão BR
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      // Formatação do horário no formato brasileiro (Hora e Minuto)
                      _horario =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),

              SizedBox(height: 20),
              // Exibindo a data selecionada
              if (_dataSelecionada != null)
                Text(
                  'Data Selecionada: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}', // Formata a data
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _mostrarCalendarioPersonalizado(context),
                child: Text('Selecionar Data'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                
                onPressed: _salvarReuniao,
                child: Text('Salvar Reunião',),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
