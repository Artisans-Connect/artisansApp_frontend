import 'package:flutter/material.dart';
import '../client_shell.dart';

/// Exposes tab switching to descendant screens inside [ClientShell].
class ClientShellScope extends InheritedWidget {
  const ClientShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final void Function(ClientNavTab tab) selectTab;

  static ClientShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClientShellScope>();
  }

  static ClientShellScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'ClientShellScope not found above $context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ClientShellScope oldWidget) => false;
}
