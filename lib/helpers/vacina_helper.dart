import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String vacinaTable = "vacinaTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class VacinaHelper {

  static final VacinaHelper _instance = VacinaHelper.internal();

  factory VacinaHelper() => _instance;

  VacinaHelper.internal();

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
    final path = join(databasesPath, "vacinasnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $vacinaTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
              "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Vacina> saveVacina(Vacina vacina) async {
    Database dbVacina = await db;
    vacina.id = await dbVacina.insert(vacinaTable, vacina.toMap());
    return vacina;
  }

  Future<Vacina> getVacina(int id) async {
    Database dbVacina = await db;
    List<Map> maps = await dbVacina.query(vacinaTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if(maps.length > 0){
      return Vacina.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteVacina(int id) async {
    Database dbVacina = await db;
    return await dbVacina.delete(vacinaTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateVacina(Vacina vacina) async {
    Database dbVacina = await db;
    return await dbVacina.update(vacinaTable,
        vacina.toMap(),
        where: "$idColumn = ?",
        whereArgs: [vacina.id]);
  }

  Future<List> getAllVacinas() async {
    Database dbVacina = await db;
    List listMap = await dbVacina.rawQuery("SELECT * FROM $vacinaTable");
    List<Vacina> listVacina = List();
    for(Map m in listMap){
      listVacina.add(Vacina.fromMap(m));
    }
    return listVacina;
  }

  Future<int> getNumber() async {
    Database dbVacina = await db;
    return Sqflite.firstIntValue(await dbVacina.rawQuery("SELECT COUNT(*) FROM $vacinaTable"));
  }

  Future close() async {
    Database dbVacina = await db;
    dbVacina.close();
  }

}

class Vacina {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Vacina();

  Vacina.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Vacina(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}