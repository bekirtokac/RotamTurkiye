class UserModel {
  final String id;
  final String name;
  final String email;
  final String city;
  String photoUrl;
  int score;
  int ticket;

  UserModel({
    this.photoUrl = "",
    this.score = 0,
    this.ticket = 0,
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'],
      email: map['email'],
      city: map['city'],
      photoUrl: map['photoUrl'] ??
          map['profileImage'] ??
          "",
      score: map['score'] ?? 0,
      ticket: map['ticket'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'city': city,
      'photoUrl': photoUrl,
      'score': score,
      'ticket': ticket,
    };
  }
}
