import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/seccion_model.dart';
import '../domain/alumno_model.dart';
import '../domain/sesion_model.dart';
import '../domain/registro_lanzamiento_model.dart';
import '../domain/nota_sesion_model.dart';

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

    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS sesiones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        totalLanzamientos INTEGER NOT NULL DEFAULT 0,
        potenciaPromedio REAL NOT NULL DEFAULT 0
      )
      ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS registros_lanzamientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sesionId INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        modo TEXT NOT NULL,
        potencia INTEGER NOT NULL,
        numeroDeLanzamiento INTEGER NOT NULL,
        FOREIGN KEY (sesionId) REFERENCES sesiones (id) ON DELETE CASCADE
      )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute(
          "ALTER TABLE alumnos ADD COLUMN nombre TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "ALTER TABLE alumnos ADD COLUMN apellido TEXT NOT NULL DEFAULT ''");
      await db.execute(
          "UPDATE alumnos SET nombre = nombreCompleto WHERE nombre = ''");
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE sesiones ADD COLUMN seccionId INTEGER');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS notas_sesion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        alumnoId INTEGER NOT NULL,
        sesionId INTEGER NOT NULL,
        nota REAL NOT NULL,
        FOREIGN KEY (alumnoId) REFERENCES alumnos (id) ON DELETE CASCADE,
        FOREIGN KEY (sesionId) REFERENCES sesiones (id) ON DELETE CASCADE,
        UNIQUE (alumnoId, sesionId)
      )
      ''');
    }
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
      nombre TEXT NOT NULL,
      apellido TEXT NOT NULL,
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

    // Tabla de Sesiones de lanzamiento
    await db.execute('''
    CREATE TABLE sesiones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fecha TEXT NOT NULL,
      totalLanzamientos INTEGER NOT NULL DEFAULT 0,
      potenciaPromedio REAL NOT NULL DEFAULT 0,
      seccionId INTEGER
    )
    ''');

    // Tabla de Registros individuales de lanzamiento
    await db.execute('''
    CREATE TABLE registros_lanzamientos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sesionId INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      modo TEXT NOT NULL,
      potencia INTEGER NOT NULL,
      numeroDeLanzamiento INTEGER NOT NULL,
      FOREIGN KEY (sesionId) REFERENCES sesiones (id) ON DELETE CASCADE
    )
    ''');

    // Tabla de Notas por sesión
    await db.execute('''
    CREATE TABLE notas_sesion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      alumnoId INTEGER NOT NULL,
      sesionId INTEGER NOT NULL,
      nota REAL NOT NULL,
      FOREIGN KEY (alumnoId) REFERENCES alumnos (id) ON DELETE CASCADE,
      FOREIGN KEY (sesionId) REFERENCES sesiones (id) ON DELETE CASCADE,
      UNIQUE (alumnoId, sesionId)
    )
    ''');
  }

  // --- MÉTODOS CRUD BÁSICOS ---

  Future<int> insertSeccion(Seccion seccion) async {
    final db = await instance.database;
    return await db.insert('secciones', seccion.toMap());
  }

  Future<int> updateSeccion(Seccion seccion) async {
    final db = await instance.database;
    return await db.update('secciones', seccion.toMap(),
        where: 'id = ?', whereArgs: [seccion.id]);
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

  // --- SESIONES ---

  Future<int> insertSesion(Sesion sesion) async {
    final db = await instance.database;
    return await db.insert('sesiones', sesion.toMap());
  }

  Future<void> updateSesion(Sesion sesion) async {
    final db = await instance.database;
    await db.update('sesiones', sesion.toMap(), where: 'id = ?', whereArgs: [sesion.id]);
  }

  Future<List<Sesion>> getSesiones() async {
    final db = await instance.database;
    final result = await db.query('sesiones', orderBy: 'fecha DESC');
    return result.map((m) => Sesion.fromMap(m)).toList();
  }

  // --- REGISTROS DE LANZAMIENTOS ---

  Future<int> insertRegistroLanzamiento(RegistroLanzamiento registro) async {
    final db = await instance.database;
    return await db.insert('registros_lanzamientos', registro.toMap());
  }

  Future<List<RegistroLanzamiento>> getRegistrosPorSesion(int sesionId) async {
    final db = await instance.database;
    final result = await db.query(
      'registros_lanzamientos',
      where: 'sesionId = ?',
      whereArgs: [sesionId],
      orderBy: 'numeroDeLanzamiento ASC',
    );
    return result.map((m) => RegistroLanzamiento.fromMap(m)).toList();
  }

  // --- NOTAS POR SESIÓN ---

  Future<void> upsertNotaSesion(NotaSesion nota) async {
    final db = await instance.database;
    await db.insert(
      'notas_sesion',
      nota.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<NotaSesion?> getNotaDeAlumnoEnSesion(
      int alumnoId, int sesionId) async {
    final db = await instance.database;
    final result = await db.query(
      'notas_sesion',
      where: 'alumnoId = ? AND sesionId = ?',
      whereArgs: [alumnoId, sesionId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return NotaSesion.fromMap(result.first);
  }

  Future<List<NotaSesion>> getNotasPorSesion(int sesionId) async {
    final db = await instance.database;
    final result = await db.query(
      'notas_sesion',
      where: 'sesionId = ?',
      whereArgs: [sesionId],
    );
    return result.map((m) => NotaSesion.fromMap(m)).toList();
  }

  Future<List<Sesion>> getSesionesPorSeccion(int seccionId) async {
    final db = await instance.database;
    final result = await db.query(
      'sesiones',
      where: 'seccionId = ?',
      whereArgs: [seccionId],
      orderBy: 'fecha ASC',
    );
    return result.map((m) => Sesion.fromMap(m)).toList();
  }

  /// Devuelve un mapa alumnoId → cantidad de notas en sesiones de esta sección
  Future<Map<int, int>> getNotasCountPorSeccion(int seccionId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT ns.alumnoId, COUNT(*) as total
      FROM notas_sesion ns
      INNER JOIN sesiones s ON s.id = ns.sesionId
      WHERE s.seccionId = ?
      GROUP BY ns.alumnoId
    ''', [seccionId]);
    return {for (final r in result) r['alumnoId'] as int: r['total'] as int};
  }
}