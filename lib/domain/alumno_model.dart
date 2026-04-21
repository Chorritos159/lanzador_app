class Alumno {
  final int? id;
  final int seccionId;
  final String nombreCompleto;

  Alumno({this.id, required this.seccionId, required this.nombreCompleto});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seccionId': seccionId,
      'nombreCompleto': nombreCompleto,
    }; // ¡AQUÍ ESTABA EL ERROR! Ya no debe haber notaRendimiento
  }

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      id: map['id'],
      seccionId: map['seccionId'],
      nombreCompleto: map['nombreCompleto'],
    );
  }
}