import 'package:flutter/material.dart';

/// Campo de seleção com busca (útil para listas grandes, como os modelos
/// de uma marca). Abre um bottom sheet com campo de pesquisa.
class PickerField extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final bool loading;
  final String? Function(String?)? validator;

  const PickerField({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.value,
    this.enabled = true,
    this.loading = false,
    this.validator,
  });

  @override
  State<PickerField> createState() => _PickerFieldState();
}

class _PickerFieldState extends State<PickerField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');

  @override
  void didUpdateWidget(covariant PickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PickerSheet(title: widget.label, items: widget.items),
    );
    if (selected != null) widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled && !widget.loading,
      onTap: _open,
      validator: (_) => widget.validator?.call(widget.value),
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: widget.loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.arrow_drop_down),
      ),
    );
  }
}

class _PickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  const _PickerSheet({required this.title, required this.items});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filtered =
        widget.items.where((i) => i.toLowerCase().contains(q)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar ${widget.title.toLowerCase()}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Nenhum resultado'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => ListTile(
                          title: Text(filtered[i]),
                          onTap: () => Navigator.pop(context, filtered[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
