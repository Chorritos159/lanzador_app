class RegistroLanzamiento {
  final int? id;
  final int sesionId;
  final String fecha; // ISO 8601
  final String modo; // "Fútbol" | "Vóley"
  final int potencia; // 1-10
  final int numeroDeLanzamiento; // consecutivo dentro de la sesión

  RegistroLanzamiento({
    this.id,
    required this.sesionId,
    required this.fecha,
    required this.modo,
    required this.potencia,
    required this.numeroDeLanzamiento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sesionId': sesionId,
      'fecha': fecha,
      'modo': modo,
      'potencia': potencia,
      'numeroDeLanzamiento': numeroDeLanzamiento,
    };
  }

  factory RegistroLanzamiento.fromMap(Map<String, dynamic> map) {
    return RegistroLanzamiento(
      id: map['id'],
      sesionId: map['sesionId'],
      fecha: map['fecha'],
      modo: map['modo'],
      potencia: map['potencia'],
      numeroDeLanzamiento: map['numeroDeLanzamiento'],
    );
  }
}
