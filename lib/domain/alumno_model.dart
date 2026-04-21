class Alumno {
  final int? id;
  final int seccionId;
  final String nombre;
  final String apellido;
  final double? notaRendimiento;

  Alumno({
    this.id,
    required this.seccionId,
    required this.nombre,
    required this.apellido,
    this.notaRendimiento,
  });

  String get nombreCompleto => '$nombre $apellido';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seccionId': seccionId,
      'nombre': nombre,
      'apellido': apellido,
      'notaRendimiento': notaRendimiento,
    };
  }

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      id: map['id'],
      seccionId: map['seccionId'],
      nombre: map['nombre'] as String? ?? map['nombreCompleto'] as String? ?? '',
      apellido: map['apellido'] as String? ?? '',
      notaRendimiento: map['notaRendimiento'],
    );
  }
}