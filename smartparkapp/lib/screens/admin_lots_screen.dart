import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/parking_provider.dart';
import '../services/api_client.dart';

class AdminLotsScreen extends StatefulWidget {
  const AdminLotsScreen({super.key});

  @override
  State<AdminLotsScreen> createState() => _AdminLotsScreenState();
}

class _AdminLotsScreenState extends State<AdminLotsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ParkingProvider>().fetchLots());
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final parking = context.watch<ParkingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Lots'),
      ),
      body: RefreshIndicator(
        onRefresh: () => parking.fetchLots(),
        child: ListView.builder(
          itemCount: parking.lots.length,
          itemBuilder: (context, index) {
            final lot = parking.lots[index];
            return ListTile(
              title: Text(lot.name),
              subtitle: Text(
                  '${lot.address ?? ''}\nSlots: ${lot.availableSlots}/${lot.totalSlots}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddLotScreen(apiClient: apiClient),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddLotScreen extends StatefulWidget {
  const AddLotScreen({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<AddLotScreen> createState() => _AddLotScreenState();
}

class _AddLotScreenState extends State<AddLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _slotsController = TextEditingController(text: '10');
  final _priceController = TextEditingController(text: '50');
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _slotsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await widget.apiClient.post(
        '/api/parking/admin/lots',
        body: {
          'name': _nameController.text,
          'address': _addressController.text,
          'latitude': double.tryParse(_latController.text) ?? 0,
          'longitude': double.tryParse(_lngController.text) ?? 0,
          'total_slots': int.tryParse(_slotsController.text) ?? 0,
          'price_per_hour': double.tryParse(_priceController.text) ?? 0,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lot created')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking Lot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _latController,
                decoration:
                    const InputDecoration(labelText: 'Latitude (e.g. 12.97)'),
              ),
              TextFormField(
                controller: _lngController,
                decoration:
                    const InputDecoration(labelText: 'Longitude (e.g. 77.59)'),
              ),
              TextFormField(
                controller: _slotsController,
                decoration:
                    const InputDecoration(labelText: 'Total slots (e.g. 10)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Price per hour (e.g. 50)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

