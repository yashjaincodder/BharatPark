class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? lastName;
  String? subscription; // New field

  UserModel({this.uid, this.email, this.firstName, this.lastName, this.subscription = "Basic"});

  // Data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      subscription: map['subscription'] ?? "Basic", // Use "Basic" if not present
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'subscription': subscription, // Include subscription in the map
    };
  }
}
