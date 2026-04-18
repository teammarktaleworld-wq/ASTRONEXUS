class Wallet {
  final String userId;
  final double balance;

  Wallet({required this.userId, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
