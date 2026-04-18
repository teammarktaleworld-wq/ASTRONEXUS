class TarotCard {
  final String name;
  final String value;
  final String type;
  final String meaningUp;
  final String meaningRev;
  final String desc;

  TarotCard({
    required this.name,
    required this.value,
    required this.type,
    required this.meaningUp,
    required this.meaningRev,
    required this.desc,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      type: json['type'] ?? '',
      meaningUp: json['meaning_up'] ?? '',
      meaningRev: json['meaning_rev'] ?? '',
      desc: json['desc'] ?? '',
    );
  }
}
