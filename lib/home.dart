import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/database.dart';
import 'package:myapp/editar.dart';
import 'package:myapp/registrar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}   

class _HomeState extends State<Home> {
  Map<DateTime, List<String>> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('reunioes').get();
    Map<DateTime, List<String>> loadedEvents = {};

    for (var doc in snapshot.docs) {
      final docData = doc.data() as Map<String, dynamic>;
      DateTime date = (docData['data'] as Timestamp).toDate();

      // Adc a data ao mapa
      if (loadedEvents[DateTime(date.year, date.month, date.day)] == null) {
        loadedEvents[DateTime(date.year, date.month, date.day)] = [];
      }
      loadedEvents[DateTime(date.year, date.month, date.day)]!
          .add(docData['nome']);
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  Future<void> _fetchEventsForSelectedDay(DateTime selectedDay) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reunioes')
        .where('data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0)))
        .where('data',
            isLessThan: Timestamp.fromDate(DateTime(selectedDay.year,
                selectedDay.month, selectedDay.day, 23, 59, 59)))
        .get();

    setState(() {
      // Atualiza a contagem de reuniões do dia que for escolhido
      _events[selectedDay] =
          snapshot.docs.map((doc) => doc['nome'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Gerenciador de Reuniões",
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
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFbbcde5),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendário',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return CalendarPage();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFBBCDE5),
                Color(0xFFC4FFB2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Próximas Reuniões",
                    style: TextStyle(
                      fontSize: 22,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _events[_selectedDay]?.isNotEmpty ?? false
                        ? "Você tem ${_events[_selectedDay]?.length} reunião(ões) hoje!"
                        : "Sem reuniões para hoje.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _addEvent,
                color: Colors.black,
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 8),
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // Função para buscar reuniões do dia selecionado
                _fetchEventsForSelectedDay(selectedDay);
              });
            },
            eventLoader: (day) {
              // Retorna o dia especificado
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFFAD8A64),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration( // 0xFF5D5F71
                color: Color(0xFF5D5F71),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildEventList(), 
        ),
      ],
    );
  }

  void _addEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Registrar(),
      ),
    );
  }

  Widget _buildEventList() {
    
    return SizedBox.shrink();
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Reuniões Agendadas',),
        centerTitle: true,
       
        
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('reunioes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final docData =
                        documents[index].data() as Map<String, dynamic>;
                    final String id = documents[index].id;

                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Color(0xFFbbcde5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          docData['nome'],
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              docData['resumo'],
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              docData['horario'],
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy').format(
                                  (docData['data'] as Timestamp).toDate()),
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color.fromARGB(255, 0, 0, 0)),
                              onPressed: () {
                                // tela de edição
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Editar(
                                      id: id,
                                      nome: docData['nome'],
                                      resumo: docData['resumo'],
                                      horario: docData['horario'],
                                      data: (docData['data'] as Timestamp)
                                          .toDate(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color.fromARGB(255, 0, 0, 0)),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xFFbbcde5),
                                      title: Text(
                                        'Excluir o ' + docData['nome'],
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 20,
                                        ),
                                      ),
                                      content: Text(
                                        'Tem certeza que deseja excluir este registro?',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 18,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  await DatabaseService()
                                                      .deleteMeeting(id);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'CONFIRMAR',
                                                  style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'CANCELAR',
                                                  style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}