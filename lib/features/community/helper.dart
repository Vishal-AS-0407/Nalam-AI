import 'package:mongo_dart/mongo_dart.dart';

class DatabaseHelper {
  static const String _mongoUri =
      "mongodb+srv://community:NS123456@cluster0.smgpcp9.mongodb.net/nurture_sync?retryWrites=true&w=majority";

  static Db? _db;

  // Initialize the database connection
  static Future<void> initDatabase() async {
    if (_db == null) {
      _db = await Db.create(_mongoUri);
      await _db!.open();
    }
  }

  // Retrieve a specific collection from the database
  static Future<DbCollection> getCollection(String collectionName) async {
    if (_db == null || !_db!.isConnected) {
      await initDatabase();
    }
    return _db!.collection(collectionName);
  }

  // Close the database connection
  static Future<void> closeDatabase() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
  }
}
