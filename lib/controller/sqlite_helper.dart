import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:utsob_ticket/controller/public_controller.dart';
import 'package:utsob_ticket/model/sqlite_counter_group_model.dart';
import 'package:utsob_ticket/model/sqlite_transaction_model.dart';
import '../model/login_model.dart';

class SQLiteHelper{
  static SQLiteHelper? _databaseController; // singleton DatabaseHelper
  static Database? _database;

  final String transactionTable = 'transactions';
  final String counterGroupTable = 'counterGroups';

  ///Transaction Field
  final String id = 'id';
  final String fromCounterId = 'fromCounterId';
  final String toGroupId = 'toGroupId';
  final String totalFare = 'totalFare';
  final String regularFare = 'regularFare';
  final String studentFare = 'studentFare';
  final String toll = 'toll';
  final String slNo = 'slNo';
  final String date = 'date';

  ///CounterGroup Field
  final String toGroupName = 'toGroupName';

  SQLiteHelper._createInstance(); //Named constructor to create instance of DatabaseHelper

  factory SQLiteHelper() {
    _databaseController ??= SQLiteHelper._createInstance();
    return _databaseController!;
  }

  void _createDB(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $transactionTable($id INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$fromCounterId TEXT, $toGroupId TEXT, $totalFare TEXT, $regularFare TEXT, $studentFare TEXT, $toll TEXT, $slNo TEXT, $date TEXT)');

    await db.execute(
        'CREATE TABLE $counterGroupTable($id INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$toGroupId TEXT, $toGroupName TEXT, $regularFare TEXT, $studentFare TEXT,'
            ' $toll TEXT)');
  }
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'utsob.db';
    var utsobDatabase = await openDatabase(path, version: 1, onCreate: _createDB);
    return utsobDatabase;
  }
  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  ///Fetch Transaction Map list from DB
  Future<List<Map<String, dynamic>>> getTransactionMapList() async {
    Database db = await database;
    var result = await db.query(transactionTable, orderBy: '$id ASC');
    return result;
  }

  ///Get Transaction List
  Future<void> getTransactionList() async {
    PublicController.pc.sqliteTransactionList.clear();
    var transactionMapList = await getTransactionMapList();
    for (int i = 0; i<transactionMapList.length; i++) {
      PublicController.pc.sqliteTransactionList.add(SqliteTransactionModel.fromMapObject(transactionMapList[i]));
    } PublicController.pc.update();
    if (kDebugMode) {print('Transactions: ${PublicController.pc.sqliteTransactionList.length}');}
  }

  ///Insert Transaction
  Future<int> insertTransaction(SqliteTransactionModel sqliteTransactionModel) async {
    Database db = await database;
    var result = await db.insert(transactionTable, sqliteTransactionModel.toMap());
    await getTransactionList();
    return result;
  }

    ///Delete Transactions
    Future<int> deleteTransactionList() async {
      Database db = await database;
      var result = await db.delete(transactionTable);
      await getTransactionList();
      PublicController.pc.update();
      return result;
    }



    ///:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

    ///Fetch CounterGroup Map list from DB
    Future<List<Map<String, dynamic>>> getCounterGroupMapList() async {
      Database db = await database;
      var result = await db.query(counterGroupTable, orderBy: '$id ASC');
      return result;
    }

    ///Get CounterGroup List
    Future<void> getCounterGroupList() async {
      PublicController.pc.sqliteCounterGroupList.clear();
      var counterGroupMapList = await getCounterGroupMapList();
      for (int i = 0; i<counterGroupMapList.length; i++) {
        PublicController.pc.sqliteCounterGroupList.add(SqliteCounterGroupModel.fromMapObject(counterGroupMapList[i]));
      } PublicController.pc.update();
      if (kDebugMode) {
        print('Total CounterGroup: ${PublicController.pc.sqliteCounterGroupList.length}');
      }
    }

    ///Delete CounterGroups
    Future<int> deleteCounterGroupList() async {
      Database db = await database;
      var result = await db.delete(counterGroupTable);
      await getCounterGroupList();
      PublicController.pc.update();
      return result;
    }

    ///Store All Counter List
    Future<void> storeAllCounterGroupToOffline(List<CounterGroupList> counterGroupList)async{
      Database db = await database;
      if(PublicController.pc.sqliteCounterGroupList.isNotEmpty) await deleteCounterGroupList();

      await Future.forEach(counterGroupList, (CounterGroupList element)async{
        SqliteCounterGroupModel counterModel = SqliteCounterGroupModel(
          element.toGroupId!.toString(),
          element.toGroupName,
          element.regularFare,
          element.studentFare,
          element.toll
        );
        await db.insert(counterGroupTable, counterModel.toMap());
      });
      await getCounterGroupList();
    }
}