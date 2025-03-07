part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

class CheckPermissionEvent extends PermissionEvent {
  final Permission permission;

  const CheckPermissionEvent(this.permission);

  @override
  List<Object?> get props => [permission];
}

class RequestPermissionEvent extends PermissionEvent {
  final Permission permission;

  const RequestPermissionEvent(this.permission);

  @override
  List<Object?> get props => [permission];
}

class RequestMultiplePermissionsEvent extends PermissionEvent {
  final List<Permission> permissions;

  const RequestMultiplePermissionsEvent(this.permissions);

  @override
  List<Object?> get props => [permissions];
}
