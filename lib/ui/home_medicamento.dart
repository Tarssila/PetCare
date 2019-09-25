import 'dart:io';

import 'package:agenda_contatos/helpers/medicamento_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'medicamento_page.dart';

enum OrderOptions {orderaz, orderza}

class HomeMedicamento extends StatefulWidget {
  @override
  _HomeMedicamentoState createState() => _HomeMedicamentoState();
}

class _HomeMedicamentoState extends State<HomeMedicamento> {

  MedicamentoHelper helper = MedicamentoHelper();

  List<Medicamento> medicamentos = List();

  @override
  void initState() {
    super.initState();

    _getAllMedicamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medicamentos"),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showMedicamentoPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: medicamentos.length,
          itemBuilder: (context, index) {
            return _medicamentoCard(context, index);
          }
      ),
    );
  }

  Widget _medicamentoCard(BuildContext context, int index){
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
                      image: medicamentos[index].img != null ?
                      FileImage(File(medicamentos[index].img)) :
                      AssetImage("images/medicamentos.png"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(medicamentos[index].name ?? "",
                      style: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(medicamentos[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(medicamentos[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
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
                        child: Text("Ligar",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                        ),
                        onPressed: (){
                          launch("tel:${medicamentos[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          _showMedicamentoPage(medicamento: medicamentos[index]);

                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Excluir",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                        ),
                        onPressed: (){
                          helper.deleteMedicamento(medicamentos[index].id);
                          setState(() {
                            medicamentos.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
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

  void _showMedicamentoPage({Medicamento medicamento}) async {
    final recMedicamento = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => MedicamentoPage(medicamento: medicamento,))
    );
    if(recMedicamento != null){
      if(medicamento != null){
        await helper.updateMedicamento(recMedicamento);
      } else {
        await helper.saveMedicamento(recMedicamento);
      }
      _getAllMedicamentos();
    }
  }

  void _getAllMedicamentos(){
    helper.getAllMedicamentos().then((list){
      setState(() {
        medicamentos = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        medicamentos.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        medicamentos.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

}
