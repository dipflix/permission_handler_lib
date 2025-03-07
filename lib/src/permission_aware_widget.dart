import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/permission_bloc.dart';

class PermissionAwareWidget extends StatelessWidget {
  final Widget granted;
  final Widget Function(VoidCallback requestPermission) buildDenied;
  final Permission permission;

  const PermissionAwareWidget({
    super.key,
    required this.granted,
    required this.buildDenied,
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        if (state.hasPermission(permission)) {
          return granted;
        }

        void requestPermission() {
          context.read<PermissionBloc>().add(
            RequestPermissionEvent(permission),
          );
        }

        return buildDenied(requestPermission);
      },
    );
  }
}
