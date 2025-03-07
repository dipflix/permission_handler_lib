import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
    final normalizedPermission = await _mapPermissionForPlatform(event.permission);
    final status = await normalizedPermission.status;

    final updatedPermissions = Map<Permission, bool>.from(state.permissions);
    updatedPermissions[normalizedPermission] = status.isGranted;

    emit(state.copyWith(permissions: updatedPermissions));
  }

  Future<void> _onRequestPermission(
      RequestPermissionEvent event,
      Emitter<PermissionState> emit,
      ) async {
    final normalizedPermission = await _mapPermissionForPlatform(event.permission);
    final status = await normalizedPermission.status;

    final updatedPermissions = Map<Permission, bool>.from(state.permissions);

    if (!status.isGranted) {
      final newStatus = await normalizedPermission.request();
      updatedPermissions[normalizedPermission] = newStatus.isGranted;

      if (newStatus.isPermanentlyDenied) {
        await openAppSettings();
      }
    } else {
      updatedPermissions[normalizedPermission] = true;
    }

    emit(state.copyWith(permissions: updatedPermissions));
  }

  Future<void> _onRequestMultiplePermissions(
      RequestMultiplePermissionsEvent event,
      Emitter<PermissionState> emit,
      ) async {
    final permissions = await Future.wait(
      event.permissions.map(_mapPermissionForPlatform),
    );
    final updatedPermissions = Map<Permission, bool>.from(state.permissions);

    final permissionsToRequest = <Permission>[];
    for (final permission in permissions) {
      if (!await permission.status.isGranted) {
        permissionsToRequest.add(permission);
      } else {
        updatedPermissions[permission] = true;
      }
    }

    if (permissionsToRequest.isNotEmpty) {
      final statusMap = await permissionsToRequest.request();
      statusMap.forEach((permission, status) {
        updatedPermissions[permission] = status.isGranted;
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      });
    }

    emit(state.copyWith(permissions: updatedPermissions));
  }

  void init(List<Permission> permissions) {
    for (final permission in permissions) {
      add(CheckPermissionEvent(permission));
    }
  }

  Future<bool> hasPermission(Permission permission) async {
    final normalizedPermission = await _mapPermissionForPlatform(permission);

    if (state.permissions.containsKey(normalizedPermission)) {
      return state.permissions[normalizedPermission]!;
    }

    final status = await normalizedPermission.status;
    add(CheckPermissionEvent(normalizedPermission));
    return status.isGranted;
  }

  Future<Permission> _mapPermissionForPlatform(Permission permission) async {
    if (!Platform.isAndroid) return permission;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (permission == Permission.storage) {
      if (sdkInt < 33) {
        return Permission.storage;
      } else if (sdkInt >= 30 && sdkInt < 33) {
        return Permission.manageExternalStorage;
      } else {
        return Permission.photos;
      }
    }
    return permission;
  }
}