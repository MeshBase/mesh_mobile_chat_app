import 'package:equatable/equatable.dart';

class RegisterModel extends Equatable {
  final String name;
  final String userName;

  const RegisterModel({required this.name, required this.userName});

  @override
  List<Object> get props => [name, userName];
}
