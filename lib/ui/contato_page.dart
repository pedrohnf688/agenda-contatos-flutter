import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

import 'package:agendacontatos/modelo/ContatoHelper.dart';

class ContatoPage extends StatefulWidget {
  final Contato contato;

  ContatoPage({this.contato});

  @override
  _ContatoPageState createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {

  Contato _editarContato;
  bool _userEdit = false;
  final _focusNome = FocusNode();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();


  @override
  void initState() {
    super.initState();

    if (widget.contato == null) {
      _editarContato = Contato();
    } else {
      _editarContato = Contato.fromMap(widget.contato.toMap());

      _nomeController.text = _editarContato.nome;
      _emailController.text = _editarContato.email;
      _telefoneController.text = _editarContato.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text(_editarContato.nome ?? "Novo Contato"),
              backgroundColor: Colors.red,
              centerTitle: true,
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (_editarContato.nome.isNotEmpty &&
                      _editarContato.nome != null) {
                    Navigator.pop(context, _editarContato);
                  } else {
                    FocusScope.of(context).requestFocus(_focusNome);
                  }
                },
                child: Icon(Icons.save),
                backgroundColor: Colors.red),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editarContato.img != null
                                ? FileImage(File(_editarContato.img))
                                : AssetImage("images/person.png"),
                            fit: BoxFit.cover),
                      ),
                    ),
                    onTap: (){
                      ImagePicker.pickImage(source: ImageSource.camera).then((file){
                        if(file == null){
                          return;
                        }
                        setState(() {
                            _editarContato.img = file.path;
                          });
                      });
                    },
                  ),
                  TextField(
                    controller: _nomeController,
                    focusNode: _focusNome,
                    decoration: InputDecoration(labelText: "Nome"),
                    onChanged: (text) {
                      _userEdit = true;
                      setState(() {
                        _editarContato.nome = text;
                      });
                    },
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    onChanged: (text) {
                      _userEdit = true;
                      _editarContato.email = text;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextField(
                    controller: _telefoneController,
                    decoration: InputDecoration(labelText: "Telefone"),
                    onChanged: (text) {
                      _userEdit = true;
                      _editarContato.telefone = text;
                    },
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            )),
        onWillPop: _requestPop);
  }

  Future<bool> _requestPop(){
    if(_userEdit){
      showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Descartar alterações?"),
          content: Text("Se sair as alterações serão perdidas."),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
              })
          ],
        );
      });
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }


}
