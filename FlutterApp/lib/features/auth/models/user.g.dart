// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  status: json['status'] as String,
  imageUrl: json['imageUrl'] as String?,
  phone: json['phone'] as String?,
  branch: json['branch'] as String?,
  account: json['account'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'status': instance.status,
  'imageUrl': instance.imageUrl,
  'phone': instance.phone,
  'branch': instance.branch,
  'account': instance.account,
};
