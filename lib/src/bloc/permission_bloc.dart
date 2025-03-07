import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';

part 'permission_event.dart';

part 'permission_state.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(const PermissionState()) {
    on<CheckPermissionEvent>(_onCheckPermission);
    on<RequestPermissionEvent>(_onRequestPermission);
    on<RequestMultiplePermissionsEvent>(_onRequestMultiplePermissions);
  }

  Future<void> _onCheckPermission(
    CheckPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    final normalizedPermission = _mapPermissionForPlatform(event.permission);
    final status = await normalizedPermission.status;

    final updatedPermissions = Map<Permission, bool>.from(state.permissions);
    updatedPermissions[normalizedPermission] = status.isGranted;

    emit(state.copyWith(permissions: updatedPermissions));
  }

  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    final normalizedPermission = _mapPermissionForPlatform(event.permission);

    if (await _isPermissionRequired(normalizedPermission)) {
      final status = await normalizedPermission.request();
      final updatedPermissions = Map<Permission, bool>.from(state.permissions);
      updatedPermissions[normalizedPermission] = status.isGranted;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      emit(state.copyWith(permissions: updatedPermissions));
    } else {
      final updatedPermissions = Map<Permission, bool>.from(state.permissions);
      updatedPermissions[normalizedPermission] = true;
      emit(state.copyWith(permissions: updatedPermissions));
    }
  }

  Future<void> _onRequestMultiplePermissions(
    RequestMultiplePermissionsEvent event,
    Emitter<PermissionState> emit,
  ) async {
    final permissions =
        event.permissions.map(_mapPermissionForPlatform).toList();
    final updatedPermissions = Map<Permission, bool>.from(state.permissions);

    final permissionsToRequest = <Permission>[];
    for (final permission in permissions) {
      if (await _isPermissionRequired(permission)) {
        permissionsToRequest.add(permission);
      } else {
        updatedPermissions[permission] = true;
      }
    }

    if (permissionsToRequest.isNotEmpty) {
      final statusMap = await permissionsToRequest.request();
      statusMap.forEach((permission, status) {
        updatedPermissions[permission] = status.isGranted;
      });
    }

    emit(state.copyWith(permissions: updatedPermissions));
  }

  void init(List<Permission> permissions) {
    for (final permission in permissions) {
      add(CheckPermissionEvent(permission));
    }
  }

  Permission _mapPermissionForPlatform(Permission permission) {
    if (!Platform.isAndroid) return permission;

    final isAndroid13OrHigher = _getAndroidApiLevel() >= 33;

    if (isAndroid13OrHigher) {
      if (permission == Permission.storage) {
        return Permission.photos;
      }
    }
    return permission;
  }

  Future<bool> _isPermissionRequired(Permission permission) async {
    if (!Platform.isAndroid) return true;

    final isAndroid13OrHigher = _getAndroidApiLevel() >= 33;

    if (isAndroid13OrHigher) {
      if (permission == Permission.storage ||
          permission == Permission.photos ||
          permission == Permission.videos ||
          permission == Permission.audio) {
        return false;
      }
    }
    return true;
  }

  int _getAndroidApiLevel() {
    final match = RegExp(
      r'API (\d+)',
    ).firstMatch(Platform.operatingSystemVersion);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
