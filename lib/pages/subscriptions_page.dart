import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';

class SubscriptionsPage extends StatefulWidget {
  final OldReaderApi api;
  const SubscriptionsPage({super.key, required this.api});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<dynamic> subscriptions = [];
  bool loading = true;
  String? error;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() { loading = true; error = null; });
    try {
      final resp = await widget.api.getSubscriptions();
      if (resp.statusCode == 200) {
        final data = resp.body;
        final json = data.isNotEmpty ? (data.contains('subscriptions') ? (data.startsWith('{') ? (data.endsWith('}') ? data : '$data}') : '{$data}') : data) : '{}';
        final map = jsonDecode(json);
        subscriptions = List.from(map['subscriptions'] ?? []);
        setState(() { loading = false; });
      } else {
        setState(() { error = 'Erro ao carregar: ${resp.statusCode}'; loading = false; });
      }
    } catch (e) {
      setState(() { error = 'Erro: $e'; loading = false; });
    }
  }

  Future<void> _addSubscription() async {
    final url = _addController.text.trim();
    if (url.isEmpty) return;
    setState(() { loading = true; });
    try {
      final resp = await widget.api.addSubscription(url);
      if (resp.statusCode == 200) {
        _addController.clear();
        await _loadSubscriptions();
      } else {
        setState(() { error = 'Erro ao adicionar: ${resp.statusCode}'; });
      }
    } catch (e) {
      setState(() { error = 'Erro: $e'; });
    }
  }

  Future<void> _editSubscription(dynamic sub) async {
    final controller = TextEditingController(text: sub['title'] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar título'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Salvar')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() { loading = true; });
      await widget.api.editSubscription(streamId: sub['id'], title: result.trim());
      await _loadSubscriptions();
    }
  }

  Future<void> _removeSubscription(dynamic sub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover assinatura'),
        content: Text('Remover o feed "${sub['title']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() { loading = true; });
      await widget.api.removeSubscription(sub['id']);
      await _loadSubscriptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assinaturas')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addController,
                              decoration: const InputDecoration(
                                labelText: 'URL do feed',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addSubscription,
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subscriptions.length,
                        itemBuilder: (context, idx) {
                          final sub = subscriptions[idx];
                          return ListTile(
                            title: Text(sub['title'] ?? sub['id'] ?? ''),
                            subtitle: Text(sub['url'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editSubscription(sub),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeSubscription(sub),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
