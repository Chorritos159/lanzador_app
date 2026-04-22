class Alumno {
  final int? id;
  final int seccionId; // Para saber a qué aula pertenece
  final String nombreCompleto;
  final double? notaRendimiento; // Puede ser nulo si el profesor aún no lo evalúa

  Alumno({this.id, required this.seccionId, required this.nombreCompleto, this.notaRendimiento});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seccionId': seccionId,
      'nombreCompleto': nombreCompleto,
      'notaRendimiento': notaRendimiento,
    };
  }

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      id: map['id'],
      seccionId: map['seccionId'],
      nombreCompleto: map['nombreCompleto'],
      notaRendimiento: map['notaRendimiento'],
    );
  }
}  
  

    