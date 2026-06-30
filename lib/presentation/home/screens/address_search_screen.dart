import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_passenger/data/repositories/geo_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

enum AddressSearchMode { pickup, destination }

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key, required this.mode});

  final AddressSearchMode mode;

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final _controller = TextEditingController();
  List<GeoPoint> _results = const [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _results = const []);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repository = context.read<GeoRepository>();
    try {
      final results = await repository.searchAddresses(
        query: query,
        lat: 56.8389,
        lon: 60.6057,
        limit: 5,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _results = const [];
        _isLoading = false;
        _errorMessage = 'Не удалось выполнить поиск адреса';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.mode == AddressSearchMode.pickup ? 'Откуда едем' : 'Куда едем';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите адрес',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _search,
                  child: const Text('Найти'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: Colors.white,
                      title: Text(item.address),
                      subtitle: Text('${item.lat}, ${item.lng}'),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
