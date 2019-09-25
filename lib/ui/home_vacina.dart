import 'dart:io';

import 'package:agenda_contatos/helpers/vacina_helper.dart';
import 'package:agenda_contatos/ui/vacina_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomeVacina extends StatefulWidget {
  @override
  _HomeVacinaState createState() => _HomeVacinaState();
}

class _HomeVacinaState extends State<HomeVacina> {

  VacinaHelper helper = VacinaHelper();

  List<Vacina> vacinas = List();

  @override
  void initState() {
    super.initState();

    _getAllVacinas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vacinas"),
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
          _showVacinaPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: vacinas.length,
          itemBuilder: (context, index) {
            return _vacinaCard(context, index);
          }
      ),
    );
  }

  Widget _vacinaCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: vacinas[index].img != null ?
                      FileImage(File(vacinas[index].img)) :
                      AssetImage("images/seringa.png"),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(vacinas[index].name ?? "",
                      style: TextStyle(fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(vacinas[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(vacinas[index].phone ?? "",
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
                          launch("tel:${vacinas[index].phone}");
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
                          _showVacinaPage(vacina: vacinas[index]);

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
                          helper.deleteVacina(vacinas[index].id);
                          setState(() {
                            vacinas.removeAt(index);
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

  void _showVacinaPage({Vacina vacina}) async {
    final recVacina = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => VacinaPage(vacina: vacina,))
    );
    if(recVacina != null){
      if(vacina != null){
        await helper.updateVacina(recVacina);
      } else {
        await helper.saveVacina(recVacina);
      }
      _getAllVacinas();
    }
  }

  void _getAllVacinas(){
    helper.getAllVacinas().then((list){
      setState(() {
        vacinas = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        vacinas.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        vacinas.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

}
