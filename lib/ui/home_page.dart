import 'package:agendacontatos/ui/contato_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:agendacontatos/modelo/ContatoHelper.dart';

enum OrderOption {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContatoHelper contatoHelper = ContatoHelper();
  List<Contato> listContatos = List();

  @override
  void initState() {
    super.initState();
    contatoHelper.getAllContato().then((lista) {
      setState(() {
        listContatos = lista;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOption>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOption>>[
                const PopupMenuItem<OrderOption>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOption.orderaz,
                ),
                const PopupMenuItem<OrderOption>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOption.orderza,
                )
              ],
            onSelected: (OrderOption result){
                switch(result){
                  case OrderOption.orderaz:
                    listContatos.sort((a, b) {
                     return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
                    });
                    break;
                  case OrderOption.orderza:
                    listContatos.sort((a, b) {
                      return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
                    });
                    break;
                }
                setState(() {

                });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showContatoPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: listContatos.length,
          itemBuilder: (context, index) {
            return _cardContato(context, index);
          }),
    );
  }

  Widget _cardContato(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: listContatos[index].img != null
                          ? FileImage(File(listContatos[index].img))
                          : AssetImage("images/person.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(listContatos[index].nome ?? "", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(listContatos[index].email ?? "", style: TextStyle(fontSize: 18.0)),
                    Text(listContatos[index].telefone ?? "", style: TextStyle(fontSize: 18.0,))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                            onPressed: () {
                              launch("tel:${listContatos[index].telefone}");
                              Navigator.pop(context);
                            },
                          )),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContatoPage(contato: listContatos[index]);
                            },
                          )),
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                            child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                            onPressed: () {
                              contatoHelper.deleteContato(listContatos[index].id);
                              setState(() {
                                listContatos.removeAt(index);
                                Navigator.pop(context);
                              });
                            },
                          ))
                    ],
                  ),
                );
              });
        });
  }

  void _showContatoPage({Contato contato}) async {
    final recContato = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContatoPage(contato: contato)));
    if (recContato != null) {
      if (contato != null) {
        await contatoHelper.updateContato(recContato);
      } else {
        await contatoHelper.saveContato(recContato);
      }
      _getAllContatos();
    }
  }


  void _getAllContatos() {
    contatoHelper.getAllContato().then((list) {
      setState(() {
        listContatos = list;
      });
    });
  }

}
