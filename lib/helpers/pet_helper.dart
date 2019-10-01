import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String petTable = "petTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String pesoColumn = "pesoColumn";

final String imgColumn = "imgColumn";

class PetHelper {

  static final PetHelper _instance = PetHelper.internal();

  factory PetHelper() => _instance;

  PetHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "petsnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $petTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $imgColumn TEXT,)"
      );
    });
  }

  Future<Pet> savePet(Pet pet) async {
    Database dbPet = await db;
    pet.id = await dbPet.insert(petTable, pet.toMap());
    return pet;
  }

  Future<Pet> getPet(int id) async {
    Database dbPet = await db;
    List<Map> maps = await dbPet.query(petTable,
      columns: [idColumn, nameColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]);
    if(maps.length > 0){
      return Pet.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletePet(int id) async {
    Database dbPet = await db;
    return await dbPet.delete(petTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updatePet(Pet pet) async {
    Database dbPet = await db;
    return await dbPet.update(petTable,
        pet.toMap(),
        where: "$idColumn = ?",
        whereArgs: [pet.id]);
  }

  Future<List> getAllPets() async {
    Database dbPet = await db;
    List listMap = await dbPet.rawQuery("SELECT * FROM $petTable");
    List<Pet> listPet = List();
    for(Map m in listMap){
      listPet.add(Pet.fromMap(m));
    }
    return listPet;
  }

  Future<int> getNumber() async {
    Database dbPet = await db;
    return Sqflite.firstIntValue(await dbPet.rawQuery("SELECT COUNT(*) FROM $petTable"));
  }

  Future close() async {
    Database dbPet = await db;
    dbPet.close();
  }

}

class Pet {

  int id;
  String name;
  String img;

  Pet();

  Pet.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];

    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,

      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Pet(id: $id, name: $name, img: $img)";
  }

}