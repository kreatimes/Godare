// Representa el reto diario asignado al usuario.
// Cada dia el sistema asigna automaticamente un reto fitness al usuario
// si este tiene retos disponibles en su inventario.
class DailyItem {
  final String? id;
  final String? type;
  final String title;
  final String state;
  final DateTime? arrivalDate;
  final bool generatedToday;

  const DailyItem({
    this.id,
    this.type,
    required this.title,
    required this.state,
    this.arrivalDate,
    required this.generatedToday,
  });

  factory DailyItem.fromJson(Map<String, dynamic> json) {
    return DailyItem(
      id: json['id'],
      type: json['type'],
      title: json['title'] ?? '',
      state: json['state'] ?? 'TRANSFERRED',
      arrivalDate: json['arrivalDate'] != null
          ? DateTime.parse(json['arrivalDate'])
          : null,
      generatedToday: json['generatedToday'] ?? false,
    );
  }

  // Comprueba si el item es un reto (por ahora todos los items son retos)
  bool get isDare => type == 'DARE';

  // Comprueba si el reto fue transferido a otro usuario
  bool get isTransferred => state == 'TRANSFERRED';
}
