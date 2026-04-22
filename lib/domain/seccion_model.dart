class Seccion {
  final int? id;
  final String nombre; 

  Seccion({this.id, required this.nombre});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }

  factory Seccion.fromMap(Map<String, dynamic> map) {
    return Seccion(id: map['id'], nombre: map['nombre']);
  }
}