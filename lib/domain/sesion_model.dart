class Sesion {
  final int? id;
  final String fecha; // ISO 8601: "2026-04-21T10:30:00"
  final int totalLanzamientos;
  final double potenciaPromedio;
  final int? seccionId;

  Sesion({
    this.id,
    required this.fecha,
    required this.totalLanzamientos,
    required this.potenciaPromedio,
    this.seccionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'totalLanzamientos': totalLanzamientos,
      'potenciaPromedio': potenciaPromedio,
      'seccionId': seccionId,
    };
  }

  factory Sesion.fromMap(Map<String, dynamic> map) {
    return Sesion(
      id: map['id'],
      fecha: map['fecha'],
      totalLanzamientos: map['totalLanzamientos'],
      potenciaPromedio: map['potenciaPromedio'],
      seccionId: map['seccionId'],
    );
  }
}

