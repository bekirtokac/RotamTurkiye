class UserModel {
  final String id;
  final String name;
  final String email;
  final String city;
  String profileImage;
  int score;
  int ticket;

  UserModel({
    this.profileImage = "./assets/icons/person.png",
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
      profileImage: map['profileImage'] ?? "./assets/icons/person.png",
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
      'profileImage': profileImage,
      'score': score,
      'ticket': ticket,
    };
  }
}
