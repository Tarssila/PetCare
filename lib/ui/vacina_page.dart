import 'dart:async';
import 'dart:io';

import 'package:agenda_contatos/helpers/vacina_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VacinaPage extends StatefulWidget {

  final Vacina vacina;

  VacinaPage({this.vacina});

  @override
  _VacinaPageState createState() => _VacinaPageState();
}

class _VacinaPageState extends State<VacinaPage> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;

  Vacina _editedVacina;

  @override
  void initState() {
    super.initState();

    if(widget.vacina == null){
      _editedVacina = Vacina();
    } else {
      _editedVacina = Vacina.fromMap(widget.vacina.toMap());

      _nameController.text = _editedVacina.name;
      _emailController.text = _editedVacina.email;
      _phoneController.text = _editedVacina.phone;
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
          title: Text(_editedVacina.name ?? "Nova Vacina"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedVacina.name != null && _editedVacina.name.isNotEmpty){
              Navigator.pop(context, _editedVacina);
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
                        image: _editedVacina.img != null ?
                        FileImage(File(_editedVacina.img)) :
                        AssetImage("images/seringa.png"),
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
                    _editedVacina.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Data"),
                onChanged: (text){
                  _userEdited = true;
                  _editedVacina.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
//              TextField(
//                controller: _phoneController,
//                decoration: InputDecoration(labelText: "Phone"),
//                onChanged: (text){
//                  _userEdited = true;
//                  _editedVacina.phone = text;
//                },
//                keyboardType: TextInputType.phone,
//              ),
              SwitchListTile(
                title: const Text('É necessário revacinar?'),
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
                              _editedVacina.img = file.path;
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
                              _editedVacina.img = file.path;
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
