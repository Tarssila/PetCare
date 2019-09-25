import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String medicamentoTable = "medicamentoTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class MedicamentoHelper {

  static final MedicamentoHelper _instance = MedicamentoHelper.internal();

  factory MedicamentoHelper() => _instance;

  MedicamentoHelper.internal();

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
    final path = join(databasesPath, "medicamentosnew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $medicamentoTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
              "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Medicamento> saveMedicamento(Medicamento medicamento) async {
    Database dbMedicamento = await db;
    medicamento.id = await dbMedicamento.insert(medicamentoTable, medicamento.toMap());
    return medicamento;
  }

  Future<Medicamento> getMedicamento(int id) async {
    Database dbMedicamento = await db;
    List<Map> maps = await dbMedicamento.query(medicamentoTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if(maps.length > 0){
      return Medicamento.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteMedicamento(int id) async {
    Database dbMedicamento = await db;
    return await dbMedicamento.delete(medicamentoTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateMedicamento(Medicamento medicamento) async {
    Database dbMedicamento = await db;
    return await dbMedicamento.update(medicamentoTable,
        medicamento.toMap(),
        where: "$idColumn = ?",
        whereArgs: [medicamento.id]);
  }

  Future<List> getAllMedicamentos() async {
    Database dbMedicamento = await db;
    List listMap = await dbMedicamento.rawQuery("SELECT * FROM $medicamentoTable");
    List<Medicamento> listMedicamento = List();
    for(Map m in listMap){
      listMedicamento.add(Medicamento.fromMap(m));
    }
    return listMedicamento;
  }

  Future<int> getNumber() async {
    Database dbMedicamento = await db;
    return Sqflite.firstIntValue(await dbMedicamento.rawQuery("SELECT COUNT(*) FROM $medicamentoTable"));
  }

  Future close() async {
    Database dbMedicamento = await db;
    dbMedicamento.close();
  }

}

class Medicamento {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Medicamento();

  Medicamento.fromMap(Map map){
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
    return "Medicamento(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}