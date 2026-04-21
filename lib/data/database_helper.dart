import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/seccion_model.dart';
import '../domain/alumno_model.dart';
import '../domain/nota_model.dart'; // Crearemos este archivo en el siguiente paso

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // CAMBIO IMPORTANTE: Renombramos la BD a v2 para que cree todo desde cero
    _database = await _initDB('lanzador_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE secciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL
    )
    ''');

    // Alumno ya no tiene la nota aquí adentro
    await db.execute('''
    CREATE TABLE alumnos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seccionId INTEGER NOT NULL,
      nombreCompleto TEXT NOT NULL,
      FOREIGN KEY (seccionId) REFERENCES secciones (id) ON DELETE CASCADE
    )
    ''');

    // NUEVA TABLA: Una tabla dedicada solo a las notas
    await db.execute('''
    CREATE TABLE notas (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      alumnoId INTEGER NOT NULL,
      nombreEvaluacion TEXT NOT NULL,
      valor REAL NOT NULL,
      FOREIGN KEY (alumnoId) REFERENCES alumnos (id) ON DELETE CASCADE
    )
    ''');
  }

  // --- MÉTODOS DE SECCIONES ---
  Future<int> insertSeccion(Seccion seccion) async {
    final db = await instance.database;
    return await db.insert('secciones', seccion.toMap());
  }

  Future<List<Seccion>> getSecciones() async {
    final db = await instance.database;
    final result = await db.query('secciones');
    return result.map((json) => Seccion.fromMap(json)).toList();
  }

  // --- MÉTODOS DE ALUMNOS ---
  Future<int> insertAlumno(Alumno alumno) async {
    final db = await instance.database;
    return await db.insert('alumnos', alumno.toMap());
  }

  Future<List<Alumno>> getAlumnosPorSeccion(int seccionId) async {
    final db = await instance.database;
    final result = await db.query('alumnos', where: 'seccionId = ?', whereArgs: [seccionId]);
    return result.map((json) => Alumno.fromMap(json)).toList();
  }

  // --- NUEVOS MÉTODOS DE NOTAS ---
  Future<int> insertNota(Nota nota) async {
    final db = await instance.database;
    return await db.insert('notas', nota.toMap());
  }

  Future<List<Nota>> getNotasPorAlumno(int alumnoId) async {
    final db = await instance.database;
    final result = await db.query('notas', where: 'alumnoId = ?', whereArgs: [alumnoId]);
    return result.map((json) => Nota.fromMap(json)).toList();
  }
}