class Seccion {
  final int? id;
  final String nombre; // Ej. "3ro A"

  Seccion({this.id, required this.nombre});

  // Convierte el objeto a un mapa para guardarlo en la Base de Datos
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }

  // Crea un objeto desde un mapa (cuando leemos la Base de Datos)
  factory Seccion.fromMap(Map<String, dynamic> map) {
    return Seccion(id: map['id'], nombre: map['nombre']);
  }
}