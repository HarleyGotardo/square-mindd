import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'item_database_helper.dart';

class SaleDatabaseHelper {
  final String userEmailOrNumber;
  final ItemDatabaseHelper itemDbHelper;

  SaleDatabaseHelper({required this.userEmailOrNumber, required this.itemDbHelper});

  String get _databaseName => 'sale_database_$userEmailOrNumber.db';

  Future<Database> get database async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _databaseName);

    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE SaleItem (
        id INTEGER PRIMARY KEY,
        itemName TEXT,
        quantity INT,
        date TEXT,
        totalPrice REAL
      )
    ''');
  }

  Future<void> addSaleItem(Map<String, dynamic> saleItem) async {
    final db = await database;
    
    // Fetch the price of the item
    final itemName = saleItem['itemName'];
    final itemPrice = await itemDbHelper.getItemPrice(itemName);

    // Calculate the total price and add it to the sale item
    final soldQuantity = saleItem['quantity'];
    final totalPrice = itemPrice * soldQuantity;
    saleItem['totalPrice'] = totalPrice;

    await db.insert('SaleItem', saleItem);

    // Update the quantity in the item database
    final items = await itemDbHelper.getItems();
    final item = items.firstWhere((item) => item['itemName'] == itemName);
    final currentQuantity = int.parse(item['quantity'] as String);
    final newQuantity = currentQuantity - soldQuantity;
    await itemDbHelper.updateItem(item['id'], {'quantity': newQuantity.toString()});
  }

  Future<List<Map<String, dynamic>>> getSaleItems() async {
    final db = await database;
    return await db.query('SaleItem');
  }
}