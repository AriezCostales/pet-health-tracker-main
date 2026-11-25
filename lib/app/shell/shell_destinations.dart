import 'package:flutter/material.dart';

/// A destination in the shell bar.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.key,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Key key;
}

/// The four destinations, in display order. The raised centre action sits
/// between the second and third.
const List<ShellDestination> shellDestinations = <ShellDestination>[
  ShellDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    key: ValueKey<String>('tab-home'),
  ),
  ShellDestination(
    label: 'Journal',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    key: ValueKey<String>('tab-journal'),
  ),
  ShellDestination(
    label: 'Appointments',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event_rounded,
    key: ValueKey<String>('tab-appointments'),
  ),
  ShellDestination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person_rounded,
    key: ValueKey<String>('tab-profile'),
  ),
];
