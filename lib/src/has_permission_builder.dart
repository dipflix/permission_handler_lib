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
    return FutureBuilder<bool>(
      future: context.read<PermissionBloc>().hasPermission(permission),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return builder(snapshot.data ?? false);
      },
    );
  }
}