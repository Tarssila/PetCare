import 'dart:io';

import 'package:agenda_contatos/helpers/pet_helper.dart';
import 'package:agenda_contatos/ui/pet_page.dart';
import 'package:agenda_contatos/ui/vacina_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePet extends StatefulWidget {
  @override
  _HomePetState createState() => _HomePetState();
}

class _HomePetState extends State<HomePet> {

  PetHelper helper = PetHelper();

  List<Pet> pets = List();

  @override
  void initState() {
    super.initState();

    _getAllPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pets"),
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
            _showPetPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            return _petCard(context, index);
          }
      ),
    );
  }

  Widget _petCard(BuildContext context, int index){
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
                        image: pets[index].img != null ?
                          FileImage(File(pets[index].img)) :
                            AssetImage("images/animal.png"),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(pets[index].name ?? "",
                        style: TextStyle(fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(pets[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(pets[index].phone ?? "",
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
                          launch("tel:${pets[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0,),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          _showPetPage(pet: pets[index]);

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
                          helper.deletePet(pets[index].id);
                          setState(() {
                            pets.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Vacinas",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                        ),
                        onPressed: (){
                          VacinaPage();
                          //Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Medicamentos",
                          style: TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                        ),
                        onPressed: (){
                          VacinaPage();
                          //Navigator.pop(context);
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

  void _showPetPage({Pet pet}) async {
    final recPet = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => PetPage(pet: pet,))
    );
    if(recPet != null){
      if(pet != null){
        await helper.updatePet(recPet);
      } else {
        await helper.savePet(recPet);
      }
      _getAllPets();
    }
  }

  void _getAllPets(){
    helper.getAllPets().then((list){
      setState(() {
        pets = list;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        pets.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        pets.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

}
