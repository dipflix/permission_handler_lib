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
    return FutureBuilder<bool>(
      future: context.read<PermissionBloc>().hasPermission(permission),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.data ?? false) {
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
