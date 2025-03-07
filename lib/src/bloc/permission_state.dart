part of 'permission_bloc.dart';

class PermissionState extends Equatable {
  final Map<Permission, bool> permissions;


  const PermissionState({
    this.permissions = const {},
  });

  PermissionState copyWith({
    Map<Permission, bool>? permissions,

  }) {
    return PermissionState(
      permissions: permissions ?? this.permissions,
    );
  }

  bool hasPermission(Permission permission) => permissions[permission] ?? false;

  @override
  List<Object?> get props => [permissions];
}