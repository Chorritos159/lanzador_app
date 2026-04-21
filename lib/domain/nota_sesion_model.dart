class NotaSesion {
  final int? id;
  final int alumnoId;
  final int sesionId;
  final double nota;

  NotaSesion({
    this.id,
    required this.alumnoId,
    required this.sesionId,
    required this.nota,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'alumnoId': alumnoId,
        'sesionId': sesionId,
        'nota': nota,
      };

  factory NotaSesion.fromMap(Map<String, dynamic> map) => NotaSesion(
        id: map['id'],
        alumnoId: map['alumnoId'],
        sesionId: map['sesionId'],
        nota: (map['nota'] as num).toDouble(),
      );
}
