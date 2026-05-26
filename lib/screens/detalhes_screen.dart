import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chamado_model.dart';
import '../providers/chamado_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'cadastro_screen.dart';

class DetalhesScreen extends StatelessWidget {
  final Chamado chamado;

  const DetalhesScreen({super.key, required this.chamado});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChamadoProvider>();
    // Busca versão mais atualizada do chamado
    final chamadoAtual = provider.chamados.firstWhere(
      (c) => c.id == chamado.id,
      orElse: () => chamado,
    );
    final concluido = chamadoAtual.status == 'Concluído';
    final corPrioridade = Helpers.corPrioridade(chamadoAtual.prioridade);
    final corStatus = Helpers.corStatus(chamadoAtual.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        actions: [
          if (!concluido)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: provider,
                      child: CadastroScreen(chamado: chamadoAtual),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabeçalho do chamado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  corPrioridade.withOpacity(0.15),
                  corPrioridade.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: corPrioridade.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: corPrioridade.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Helpers.iconCategoria(chamadoAtual.categoria),
                        color: corPrioridade,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chamadoAtual.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadge(chamadoAtual.prioridade, corPrioridade),
                    const SizedBox(width: 8),
                    _buildBadge(chamadoAtual.status, corStatus),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Informações detalhadas
          _buildSecao(
            context,
            titulo: 'Informações',
            children: [
              _buildInfoRow(context, Icons.category_outlined, 'Categoria',
                  chamadoAtual.categoria),
              _buildInfoRow(context, Icons.location_on_outlined, 'Bairro',
                  chamadoAtual.bairro),
              _buildInfoRow(context, Icons.person_outline, 'Responsável',
                  chamadoAtual.responsavel),
              _buildInfoRow(context, Icons.calendar_today_outlined, 'Data de Abertura',
                  Helpers.formatarData(chamadoAtual.data)),
              _buildInfoRow(
                context,
                Icons.access_time_rounded,
                'Tempo Aberto',
                // Regra 7: Tempo calculado automaticamente
                Helpers.tempoDesdeAbertura(chamadoAtual.data),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Descrição
          _buildSecao(
            context,
            titulo: 'Descrição',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  chamadoAtual.descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Atualização de status
          _buildSecao(
            context,
            titulo: 'Atualizar Status',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: concluido
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_rounded,
                                color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Chamado concluído — não editável',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: AppConstants.statusList.map((s) {
                          final selecionado = chamadoAtual.status == s;
                          final cor = Helpers.corStatus(s);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: selecionado
                                  ? null
                                  : () async {
                                      final erro = await provider
                                          .atualizarStatus(chamadoAtual.id!, s);
                                      if (context.mounted && erro != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(erro),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? cor.withOpacity(0.15)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selecionado
                                        ? cor
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selecionado
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: selecionado ? cor : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      s,
                                      style: TextStyle(
                                        color: selecionado ? cor : null,
                                        fontWeight: selecionado
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSecao(
    BuildContext context, {
    required String titulo,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
