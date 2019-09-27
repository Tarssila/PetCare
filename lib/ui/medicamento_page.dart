import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/medicamento_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MedicamentoPage extends StatefulWidget {

  final Medicamento medicamento;

  MedicamentoPage({this.medicamento});

  @override
  _MedicamentoPageState createState() => _MedicamentoPageState();
}

class _MedicamentoPageState extends State<MedicamentoPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  Medicamento _editedMedicamento;

  @override
  void initState() {
    super.initState();

    if(widget.medicamento == null){
      _editedMedicamento = Medicamento();
    } else {
      _editedMedicamento = Medicamento.fromMap(widget.medicamento.toMap());

      _nameController.text = _editedMedicamento.name;
      _emailController.text = _editedMedicamento.email;
      _phoneController.text = _editedMedicamento.phone;
    }
  }

  @override
  Widget build(BuildContext context) {

    bool _lights = false;

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(_editedMedicamento.name ?? "Novo Medicamento"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedMedicamento.name != null && _editedMedicamento.name.isNotEmpty){
              Navigator.pop(context, _editedMedicamento);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.deepOrange,
        ),
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
                        image: _editedMedicamento.img != null ?
                        FileImage(File(_editedMedicamento.img)) :
                        AssetImage("images/medicamentos.png"),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                onTap: (){
                  _showOptions(context);
                },
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedMedicamento.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedMedicamento.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedMedicamento.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
              SwitchListTile(
                title: const Text('Uso Contínuo'),
                value: _lights,
                onChanged: (bool value) { setState(() { _lights = value; }); },
                secondary: const Icon(Icons.assignment_late),
              ),
              SwitchListTile(
                title: const Text('Uso Temporário'),
                value: _lights,
                onChanged: (bool value) { setState(() { _lights = value; }); },
                secondary: const Icon(Icons.assignment_late),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
            onClosing: (){},
            builder: (context){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Galeria",
                          style: TextStyle(color: Colors.teal, fontSize: 20.0),
                        ),
                        onPressed: (){
                          //launch("tel:${ads[index].phone}");
                          ImagePicker.pickImage(source: ImageSource.gallery).then((file){
                            if(file == null) return;
                            setState(() {
                              _editedMedicamento.img = file.path;
                            });
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Camera",
                          style: TextStyle(color: Colors.teal, fontSize: 20.0),
                        ),
                        onPressed: (){
                          ImagePicker.pickImage(source: ImageSource.camera).then((file){
                            if(file == null) return;
                            setState(() {
                              _editedMedicamento.img = file.path;
                            });
                          });
                          Navigator.pop(context);
                        },
                        /*onPressed: (){
                          Navigator.pop(context);
                          _showAdPage(ad: ads[index]);
                        },*/

                      ),
                    ),

                  ],
                ),
              );
            },
          );
        }
    );
  }



  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title: Text("Descartar Alterações?"),
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
                  },
                ),
              ],
            );
          }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

}
