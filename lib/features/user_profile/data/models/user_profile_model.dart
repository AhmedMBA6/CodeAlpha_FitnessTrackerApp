class UserProfileModel {
  final String uid;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String gender;

  UserProfileModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'],
      name: map['name'],
      age: map['age'],
      weight: map['weight'].toDouble(),
      height: map['height'].toDouble(),
      gender: map['gender'],
    );
  }

}