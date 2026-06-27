import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';

class SettingsPage extends StatefulWidget {
  final OldReaderApi api;
  final VoidCallback onLogout;

  const SettingsPage({super.key, required this.api, required this.onLogout});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String>? _categories;
  bool _loadingCategories = true;
  bool _exportingOpml = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await widget.api.getCategories();
      if (mounted) setState(() { _categories = cats; _loadingCategories = false; });
    } catch (_) {
      if (mounted) setState(() { _categories = []; _loadingCategories = false; });
    }
  }

  Future<void> _exportOpml() async {
    setState(() => _exportingOpml = true);
    try {
      final resp = await widget.api.exportOpml();
      if (!mounted) return;
      final msg = resp.statusCode == 200
          ? 'OPML exportado com sucesso (${resp.bodyBytes.length} bytes)'
          : 'Erro ao exportar OPML: ${resp.statusCode}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingOpml = false);
    }
  }

  Future<void> _removeCategory(String name) async {
    try {
      await widget.api.removeTag('user/-/label/$name');
      setState(() => _categories?.remove(name));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "$name" removida.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover categoria: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Conta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Exportar OPML'),
          subtitle: const Text('Baixar lista de assinaturas'),
          trailing: _exportingOpml
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
          onTap: _exportingOpml ? null : _exportOpml,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sair', style: TextStyle(color: Colors.red)),
          onTap: widget.onLogout,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              const Text('Categorias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _loadCategories,
                tooltip: 'Recarregar',
              ),
            ],
          ),
        ),
        if (_loadingCategories)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_categories == null || _categories!.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.grey)),
          )
        else
          ...(_categories!.map((name) => Dismissible(
            key: Key(name),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _removeCategory(name),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeCategory(name),
              ),
            ),
          ))),
      ],
    );
  }
}
