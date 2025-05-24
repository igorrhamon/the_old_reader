import 'package:flutter/material.dart';
import 'dart:convert';
import './../services/old_reader_api.dart';

/// This screen allows the user to add a new RSS feed by providing its URL.
/// The feed URL is validated before sending a request to The Old Reader API.
class AddFeedPage extends StatefulWidget {
  final OldReaderApi api;
  
  const AddFeedPage({
    Key? key,
    required this.api,
  }) : super(key: key);

  @override
  _AddFeedPageState createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  List<String> _categorias = ['Categoria'];
  String? _categoriaSelecionada;
  bool _categoriasLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchCategorias();
  }

  Future<void> _fetchCategorias() async {
    setState(() {
      _categoriasLoading = true;
    });
    try {
      final response = await widget.api.getTags();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tags = data['tags'] as List<dynamic>?;
        if (tags != null) {
          final nomes = tags
              .map((tag) => tag['label'] as String?)
              .where((label) => label != null && label.isNotEmpty)
              .toList();
          setState(() {
            _categorias = ['Categoria', ...nomes.cast<String>()];
          });
        }
      }
    } catch (e) {
      // Ignora erro, mantém categorias default
    } finally {
      setState(() {
        _categoriasLoading = false;
      });
    }
  }
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  /// Validates if the given URL is valid.
  bool isValidURL(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  /// Sends a request to add the new feed to The Old Reader.
  Future<void> _submitFeed() async {
    final String feedUrl = _urlController.text.trim();

    // Check if the feed URL is valid.
    if (!isValidURL(feedUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida. Verifique e tente novamente.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the OldReaderApi to add the subscription
      final response = await widget.api.addSubscription(feedUrl);

      if (response.statusCode == 200) {
        // Parse the response to check for error messages
        final responseBody = response.body;
        if (responseBody.contains("error")) {
          // The Old Reader API returns error message in the responseBody
          final errorStartIndex = responseBody.indexOf("error") + 8; // "error":"
          final errorEndIndex = responseBody.indexOf("\"", errorStartIndex);
          final errorMessage = responseBody.substring(errorStartIndex, errorEndIndex);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao adicionar o feed: $errorMessage')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feed adicionado com sucesso!')),
          );
          _urlController.clear();
          
          // Return to previous screen
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao adicionar o feed. Código: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar com a API: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Adicionar Feed', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL do Feed',
                  hintText: 'Ex: https://blog.theoldreader.com/rss',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  prefixIcon: const Icon(Icons.rss_feed),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a URL do Feed';
                  } else if (!isValidURL(value.trim())) {
                    return 'URL inválida. Verifique e tente novamente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Dropdown de Categoria estilizado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _categoriasLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<String>(
                        value: _categoriaSelecionada ?? _categorias[0],
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF756a81)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF141216),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.95),
                        items: _categorias.map((String categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria, style: const TextStyle(color: Color(0xFF141216))),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoriaSelecionada = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == _categorias[0]) {
                            return 'Selecione uma categoria';
                          }
                          return null;
                        },
                      ),
              ),
              const SizedBox(height: 16.0),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _submitFeed();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Adicionar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'Adicione a URL do feed RSS que deseja acompanhar. A URL deve começar com http:// ou https://',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
