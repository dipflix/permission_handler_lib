# Permission Handler BLoC

A Flutter library built on top of `permission_handler` and `flutter_bloc` to manage runtime permissions in a reactive and scalable way. This library provides a `PermissionBloc` for handling permission states and events, and a `PermissionAwareWidget` for building UI components that react to permission changes.

## Features

- Centralized permission management using BLoC pattern
- Reactive UI updates with `PermissionAwareWidget`
- Platform-aware permission handling (special support for Android 13+)
- Support for single and multiple permission requests
- Automatic mapping of legacy permissions to Android 13+ granular media permissions
