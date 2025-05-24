import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import '../pages/add_feed_page.dart';

class SubscriptionsPage extends StatefulWidget {
  final OldReaderApi api;
  const SubscriptionsPage({super.key, required this.api});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {  
  List<dynamic> subscriptions = [];
  List<String> categories = [];
  bool loading = true;
  bool loadingCategories = true;
  String? error;
  final TextEditingController _addController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() { loadingCategories = true; });
    try {
      // Usar o novo método para buscar categorias
      final categoryList = await widget.api.getCategories();
      setState(() { 
        categories = categoryList;
        loadingCategories = false;
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      setState(() { loadingCategories = false; });
    }
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

  Future<void> _assignCategory(dynamic sub) async {
    if (categories.isEmpty) {
      // Se não tiver categorias, mostrar mensagem e retornar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma categoria disponível')),
      );
      return;
    }

    // Obter categorias atuais da assinatura
    List<String> currentCategories = [];
    
    if (sub.containsKey('categories') && sub['categories'] is List) {
      for (var cat in sub['categories']) {
        if (cat is Map && cat.containsKey('label')) {
          String categoryName = cat['label'];
          if (categoryName.startsWith('user/-/label/')) {
            categoryName = categoryName.replaceFirst('user/-/label/', '');
          }
          currentCategories.add(categoryName);
        }
      }
    }

    // Valor inicial para dropdown (primeira categoria atual ou primeira da lista)
    String? initialCategory = currentCategories.isNotEmpty 
        ? currentCategories.first 
        : (categories.isNotEmpty ? categories.first : null);

    // Mostrar diálogo com dropdown de categorias
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atribuir à categoria'),
        content: DropdownButtonFormField<String>(
          value: initialCategory,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          items: categories.map((cat) => DropdownMenuItem(
            value: cat,
            child: Text(cat),
          )).toList(),
          onChanged: (value) => initialCategory = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, initialCategory),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() { loading = true; });
      
      try {
        // Remover categorias atuais e adicionar a nova
        // Primeiro, remover todas as categorias atuais
        for (var oldCat in currentCategories) {
          await widget.api.editSubscription(
            streamId: sub['id'],
            removeLabel: 'user/-/label/$oldCat',
          );
        }
        
        // Depois, adicionar a nova categoria
        await widget.api.editSubscription(
          streamId: sub['id'],
          addLabel: 'user/-/label/$result',
        );
        
        // Recarregar assinaturas
        await _loadSubscriptions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar categoria: $e')),
        );
        setState(() { loading = false; });
      }
    }
  }

  Future<void> _createCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da categoria',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() { loading = true; });
      
      try {
        // Criar nova categoria (usando o método criado no OldReaderApi)
        await widget.api.createCategory(result);
        
        // Recarregar categorias
        await _loadCategories();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "$result" criada com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar categoria: $e')),
        );
      } finally {
        setState(() { loading = false; });
      }
    }
  }

  // Extrair a categoria de uma assinatura para exibir no UI
  String _getSubscriptionCategory(dynamic sub) {
    if (sub.containsKey('categories') && sub['categories'] is List) {
      for (var cat in sub['categories']) {
        if (cat is Map && cat.containsKey('label')) {
          String categoryPath = cat['label'];
          if (categoryPath.startsWith('user/-/label/')) {
            return categoryPath.replaceFirst('user/-/label/', '');
          }
        }
      }
    }
    return 'Sem categoria';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Nova categoria',
            onPressed: _createCategory,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadSubscriptions,
          ),
        ],
      ),
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
                                hintText: 'https://exemplo.com/feed',
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
                      child: RefreshIndicator(
                        onRefresh: _loadSubscriptions,
                        child: ListView.builder(
                          itemCount: subscriptions.length,
                          itemBuilder: (context, idx) {
                            final sub = subscriptions[idx];
                            final String categoryName = _getSubscriptionCategory(sub);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, 
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                title: Text(
                                  sub['title'] ?? sub['id'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sub['url'] ?? ''),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, 
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.category_outlined),
                                      tooltip: 'Atribuir categoria',
                                      onPressed: () => _assignCategory(sub),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Editar título',
                                      onPressed: () => _editSubscription(sub),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Remover feed',
                                      onPressed: () => _removeSubscription(sub),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFeedPage(api: widget.api),
            ),
          ).then((result) {
            if (result == true) {
              // Se um feed foi adicionado, atualizar a lista
              _loadSubscriptions();
            }
          });
        },
        tooltip: 'Adicionar Feed',
        child: const Icon(Icons.add),
      ),
    );
  }
}
