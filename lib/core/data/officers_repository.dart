class Officer {
  final String name;
  final String email;
  final String password; // stored in-memory only

  Officer({required this.name, required this.email, required this.password});
}

class OfficersRepository {
  OfficersRepository._();
  static final OfficersRepository instance = OfficersRepository._();

  final List<Officer> _officers = [
    Officer(name: 'ABUBKAR', email: 'abubkar@example.com', password: 'password'),
    Officer(name: 'MUBASHRA', email: 'mubashra@example.com', password: 'password'),
    Officer(name: 'RIZWAN', email: 'rizwan@example.com', password: 'password'),
  ];

  List<Officer> get officers => List.unmodifiable(_officers);
  List<String> get names => _officers.map((o) => o.name).toList(growable: false);

  void addOfficer(Officer officer) {
    if (!_officers.any((o) => o.name == officer.name || o.email == officer.email)) {
      _officers.add(officer);
    }
  }

  void removeByName(String name) {
    _officers.removeWhere((o) => o.name == name);
  }
}
