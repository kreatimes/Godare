// Modelo del pack disponible en la tienda.
// Los packs contienen retos fitness que se asignan al usuario al comprarlos.
// El precio se paga con las monedas que el usuario gana completando retos.
class PackStore {
  final int id;
  final String name;
  final String type; // Por ahora todos son DARE (retos), se mantiene por compatibilidad
  final int quantity; // Numero de retos que incluye el pack
  final int priceCoins;
  final String description;
  final String? imageUrl;

  const PackStore({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.priceCoins,
    required this.description,
    this.imageUrl,
  });

  factory PackStore.fromJson(Map<String, dynamic> json) {
    return PackStore(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'],
      priceCoins: json['priceCoins'],
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  // Etiqueta visible del tipo de pack en la UI
  String get typeLabel {
    switch (type) {
      case 'DARE':
        return 'Retos Fitness';
      default:
        return type;
    }
  }
}

// Respuesta del servidor al comprar un pack correctamente.
// Devuelve las monedas restantes para actualizar el saldo en la UI.
class PackPurchaseResponse {
  final String message;
  final int remainingCoins;
  final int generatedItems; // Numero de retos que se han generado para el usuario

  const PackPurchaseResponse({
    required this.message,
    required this.remainingCoins,
    required this.generatedItems,
  });

  factory PackPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PackPurchaseResponse(
      message: json['message'],
      remainingCoins: json['remainingCoins'] ?? 0,
      generatedItems: json['generatedItems'] ?? 0,
    );
  }
}
