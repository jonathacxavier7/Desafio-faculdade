import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chamado_model.dart';
import '../providers/chamado_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class CadastroScreen extends StatefulWidget {
  final Chamado? chamado;

  const CadastroScreen({super.key, this.chamado});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _responsavelController = TextEditingController();

  String? _categoria;
  String? _prioridade;
  String? _bairro;
  String _status = 'Aberto';
  bool _salvando = false;

  bool get _editando => widget.chamado != null;

  @override
  void initState() {
    super.initState();
    if (_editando) {
      final c = widget.chamado!;
      _tituloController.text = c.titulo;
      _descricaoController.text = c.descricao;
      _responsavelController.text = c.responsavel;
      _categoria = c.categoria;
      _prioridade = c.prioridade;
      _bairro = c.bairro;
      _status = c.status;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final provider = context.read<ChamadoProvider>();
    final chamado = Chamado(
      id: widget.chamado?.id,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      categoria: _categoria!,
      prioridade: _prioridade!,
      bairro: _bairro!,
      responsavel: _responsavelController.text.trim(),
      status: _status,
      data: widget.chamado?.data ?? DateTime.now(),
    );

    String? erro;
    if (_editando) {
      erro = await provider.atualizarChamado(chamado);
    } else {
      erro = await provider.adicionarChamado(chamado);
    }

    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editando
              ? 'Chamado atualizado com sucesso!'
              : 'Chamado registrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Chamado' : 'Novo Chamado'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            _buildLabel('Título do Chamado *'),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Ex: Buraco na Rua das Flores',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: Validators.validarTitulo,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Descrição
            _buildLabel('Descrição *'),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                hintText: 'Descreva o problema em detalhes...',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: Validators.validarDescricao,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Categoria
            _buildLabel('Categoria *'),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text('Selecione a categoria'),
              items: AppConstants.categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              validator: Validators.validarCategoria,
              onChanged: (v) => setState(() => _categoria = v),
            ),
            const SizedBox(height: 16),

            // Prioridade
            _buildLabel('Prioridade *'),
            DropdownButtonFormField<String>(
              value: _prioridade,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              hint: const Text('Selecione a prioridade'),
              items: AppConstants.prioridades.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _corPrioridade(p),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(p),
                    ],
                  ),
                );
              }).toList(),
              validator: Validators.validarPrioridade,
              onChanged: (v) => setState(() => _prioridade = v),
            ),
            const SizedBox(height: 16),

            // Bairro
            _buildLabel('Bairro *'),
            DropdownButtonFormField<String>(
              value: _bairro,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              hint: const Text('Selecione o bairro'),
              items: AppConstants.bairros
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Selecione o bairro' : null,
              onChanged: (v) => setState(() => _bairro = v),
            ),
            const SizedBox(height: 16),

            // Responsável
            _buildLabel('Responsável *'),
            TextFormField(
              controller: _responsavelController,
              decoration: const InputDecoration(
                hintText: 'Nome do responsável',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: Validators.validarResponsavel,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Status
            _buildLabel('Status'),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.circle_outlined),
              ),
              items: AppConstants.statusList
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 32),

            // Botão salvar
            ElevatedButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_editando ? Icons.save_rounded : Icons.send_rounded),
              label: Text(_editando ? 'Salvar Alterações' : 'Registrar Chamado'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Color _corPrioridade(String p) {
    switch (p) {
      case 'Crítica':
        return const Color(0xFFD32F2F);
      case 'Alta':
        return const Color(0xFFF57C00);
      case 'Média':
        return const Color(0xFFF9A825);
      default:
        return const Color(0xFF388E3C);
    }
  }
}
