class Nota {
  final int? id;
  final int alumnoId;
  final String nombreEvaluacion; 
  final double valor;

  Nota({this.id, required this.alumnoId, required this.nombreEvaluacion, required this.valor});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alumnoId': alumnoId,
      'nombreEvaluacion': nombreEvaluacion,
      'valor': valor,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      alumnoId: map['alumnoId'],
      nombreEvaluacion: map['nombreEvaluacion'],
      valor: map['valor'],
    );
  }
}