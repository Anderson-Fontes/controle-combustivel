import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'refuel_form_screen.dart';
import 'refuel_list_screen.dart';
import 'vehicle_screen.dart';

/// Tela principal: navegação inferior entre Dashboard, Abastecimentos e Veículo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Abastecimentos', 'Meu veículo'];
  static const _pages = [DashboardScreen(), RefuelListScreen(), VehicleScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RefuelFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Abastecer'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station_outlined),
            selectedIcon: Icon(Icons.local_gas_station),
            label: 'Abastecimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Veículo',
          ),
        ],
      ),
    );
  }
}
