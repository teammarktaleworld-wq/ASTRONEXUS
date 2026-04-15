import '../../../../../Model/product_model.dart';

String astrologyLabel(AstrologyType type) {
  return type.name.toUpperCase();
}

String deliveryLabel(DeliveryType type) {
  return type.name.toUpperCase();
}

String stockLabel(int stock) {
  return stock > 0 ? "IN STOCK" : "OUT OF STOCK";
}
