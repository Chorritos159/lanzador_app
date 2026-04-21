import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/seccion_model.dart';
import '../domain/alumno_model.dart';

class DatabaseHelper {
  // Patrón Singleton para usar siempre la misma conexión
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lanzador_colegio.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Abre la BD y llama a _createDB si es la primera vez que se ejecuta
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabla de Secciones (Aulas)
    await db.execute('''
    CREATE TABLE secciones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL
    )
    ''');

    // Tabla de Alumnos (Vinculada al Aula)
    await db.execute('''
    CREATE TABLE alumnos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seccionId INTEGER NOT NULL,
      nombreCompleto TEXT NOT NULL,
      notaRendimiento REAL,
      FOREIGN KEY (seccionId) REFERENCES secciones (id) ON DELETE CASCADE
    )
    ''');
    // tabla NOTAS
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

  // --- MÉTODOS CRUD BÁSICOS ---

  Future<int> insertSeccion(Seccion seccion) async {
    final db = await instance.database;
    return await db.insert('secciones', seccion.toMap());
  }

  Future<int> insertAlumno(Alumno alumno) async {
    final db = await instance.database;
    return await db.insert('alumnos', alumno.toMap());
  }

  Future<List<Seccion>> getSecciones() async {
    final db = await instance.database;
    final result = await db.query('secciones');
    return result.map((json) => Seccion.fromMap(json)).toList();
  }

  Future<List<Alumno>> getAlumnosPorSeccion(int seccionId) async {
    final db = await instance.database;
    final result = await db.query('alumnos', where: 'seccionId = ?', whereArgs: [seccionId]);
    return result.map((json) => Alumno.fromMap(json)).toList();
  }
  
  Future<int> updateNotaAlumno(int id, double nota) async {
    final db = await instance.database;
    return await db.update('alumnos', {'notaRendimiento': nota}, where: 'id = ?', whereArgs: [id]);
  }
}

