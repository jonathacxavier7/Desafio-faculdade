import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chamado_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'chamados';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sos_cidade.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _criarTabela,
    );
  }

  Future<void> _criarTabela(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        descricao TEXT,
        categoria TEXT,
        prioridade TEXT,
        bairro TEXT,
        responsavel TEXT,
        status TEXT,
        data TEXT
      )
    ''');
  }

  Future<int> inserir(Chamado chamado) async {
    final db = await database;
    return await db.insert(_tableName, chamado.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Chamado>> buscarTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: "CASE prioridade WHEN 'Crítica' THEN 0 WHEN 'Alta' THEN 1 WHEN 'Média' THEN 2 ELSE 3 END, data DESC",
    );
    return List.generate(maps.length, (i) => Chamado.fromMap(maps[i]));
  }

  Future<int> atualizar(Chamado chamado) async {
    final db = await database;
    return await db.update(
      _tableName,
      chamado.toMap(),
      where: 'id = ?',
      whereArgs: [chamado.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> tituloExiste(String titulo, {int? excluirId}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: excluirId != null ? 'titulo = ? AND id != ?' : 'titulo = ?',
      whereArgs: excluirId != null ? [titulo, excluirId] : [titulo],
    );
    return result.isNotEmpty;
  }
}
