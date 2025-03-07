import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/permission_bloc.dart';

class HasPermissionBuilder extends StatelessWidget {
  final Widget Function(bool hasPermission) builder;
  final Permission permission;

  const HasPermissionBuilder({
    super.key,
    required this.permission,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionBloc, PermissionState>(
      builder: (context, state) {
        return builder(state.hasPermission(permission));
      },
    );
  }
}
