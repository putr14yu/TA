enum StatusKoas {
  pending,
  approved,
  rejected,
}

class KoasProfileModel {
  final String? id;
  final String? koasNumber;
  final String? age;
  final String? gender;
  final String? departement;
  final String? university;
  final String? bio;
  final String? whatsappLink;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updateAt;


  KoasProfileModel({
    this.id,
    this.koasNumber,
    this.age,
    this.gender,
    this.departement,
    this.university,
    this.bio,
    this.whatsappLink,
    this.status,
    this.createdAt,
    this.updateAt,

  });

  // Static function to create an empty user model
  static KoasProfileModel empty() {
    return KoasProfileModel(
      id: '',
      koasNumber: '',
      age: '',
      gender: '',
      departement: '',
      university: '',
      bio: '',
      whatsappLink: '',
      status: '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'koasNumber': koasNumber,
      'age': age,
      'gender': gender,
      'departement': departement,
      'university': university,
      'bio': bio,
      'whatsappLink': whatsappLink,
      'status': status ?? 'Pending',
    };
  }

  factory KoasProfileModel.fromJson(Map<String, dynamic> json) {
    return KoasProfileModel(
      id: json['id'] ?? '',
      koasNumber: json['koasNumber'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? '',
      departement: json['departement'] ?? '',
      university: json['university'] ?? '',
      bio: json['bio'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updateAt:
          json['updateAt'] != null ? DateTime.tryParse(json['updateAt']) : null,
    );
  }
}