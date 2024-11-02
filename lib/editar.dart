import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database.dart';
import 'package:intl/intl.dart';

class Editar extends StatefulWidget {
  final String id;
  final String nome;
  final String resumo;
  final String horario;
  final DateTime data;

  const Editar({
    Key? key,
    required this.id,
    required this.nome,
    required this.resumo,
    required this.horario,
    required this.data,
  }) : super(key: key);

  @override
  _EditarState createState() => _EditarState();
}

class _EditarState extends State<Editar> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _resumoController = TextEditingController();
  String _horario = '';
  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.nome;
    _resumoController.text = widget.resumo;
    _horario = widget.horario;
    _dataSelecionada = widget.data;
  }

  Future<void> _mostrarCalendarioPersonalizado(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: 500,
            height: 500,
            child: CalendarDatePicker(
              initialDate: _dataSelecionada ?? DateTime.now(),
              firstDate: DateTime.now(),
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

  void _editarReuniao() {
    if (_nomeController.text.isNotEmpty &&
        _resumoController.text.isNotEmpty &&
        _horario.isNotEmpty &&
        _dataSelecionada != null) {
      _databaseService.updateMeeting(
        widget.id,
        _nomeController.text,
        _resumoController.text,
        _horario,
        _dataSelecionada!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reunião editada com sucesso!')),
      );

      Navigator.pop(context); // Volta para a tela anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Reunião'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
            ElevatedButton(
              onPressed: () => _mostrarCalendarioPersonalizado(context),
              child: Text('Selecionar Data'),
            ),
            SizedBox(height: 10),
            Text(
              _dataSelecionada != null
                  ? 'Data selecionada: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada!)}'
                  : 'Nenhuma data selecionada',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editarReuniao,
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
