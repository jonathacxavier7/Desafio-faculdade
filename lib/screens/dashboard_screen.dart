import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/chamado_provider.dart';
import '../utils/constants.dart';
import '../widgets/alert_widget.dart';
import '../widgets/chamado_card.dart';
import '../widgets/status_card.dart';
import 'cadastro_screen.dart';
import 'detalhes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChamadoProvider>().carregarChamados();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirFiltros(BuildContext context) {
    final provider = context.read<ChamadoProvider>();
    String bairro = provider.filtroBairro;
    String prioridade = provider.filtroPrioridade;
    String status = provider.filtroStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filtros',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        provider.limparFiltros();
                        _buscaController.clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownFiltro(
                  label: 'Bairro',
                  value: bairro,
                  items: ['', ...AppConstants.bairros],
                  onChanged: (v) => setModalState(() => bairro = v ?? ''),
                ),
                const SizedBox(height: 10),
                _buildDropdownFiltro(
                  label: 'Prioridade',
                  value: prioridade,
                  items: ['', ...AppConstants.prioridades],
                  onChanged: (v) => setModalState(() => prioridade = v ?? ''),
                ),
                const SizedBox(height: 10),
                _buildDropdownFiltro(
                  label: 'Status',
                  value: status,
                  items: ['', ...AppConstants.statusList],
                  onChanged: (v) => setModalState(() => status = v ?? ''),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.setFiltroBairro(bairro);
                    provider.setFiltroPrioridade(prioridade);
                    provider.setFiltroStatus(status);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Aplicar Filtros'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildDropdownFiltro({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.isEmpty ? 'Todos' : e),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final dataFormatada =
        DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'pt_BR').format(agora);
    final horaFormatada = DateFormat('HH:mm').format(agora);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_city, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'SOS Cidade',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDark ? 'Tema Claro' : 'Tema Escuro',
          ),
        ],
      ),
      body: Consumer<ChamadoProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.carregarChamados,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com data/hora
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white60, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  dataFormatada,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                const Spacer(),
                                const Icon(Icons.access_time,
                                    color: Colors.white60, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  horaFormatada,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Cards de status em grid
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.8,
                              children: [
                                StatusCard(
                                  titulo: 'Total',
                                  quantidade: provider.totalChamados,
                                  cor: Colors.white,
                                  icone: Icons.list_alt_rounded,
                                ),
                                StatusCard(
                                  titulo: 'Abertos',
                                  quantidade: provider.chamadosAbertos,
                                  cor: const Color(0xFF64B5F6),
                                  icone: Icons.folder_open_rounded,
                                ),
                                StatusCard(
                                  titulo: 'Em Andamento',
                                  quantidade: provider.chamadosEmAndamento,
                                  cor: const Color(0xFFFFB74D),
                                  icone: Icons.autorenew_rounded,
                                ),
                                StatusCard(
                                  titulo: 'Concluídos',
                                  quantidade: provider.chamadosConcluidos,
                                  cor: const Color(0xFF81C784),
                                  icone: Icons.check_circle_outline_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Alerta crítico (Regra 2)
                      if (provider.alertaCritico)
                        AlertWidget(
                            quantidadeCriticos: provider.chamadosCriticos),

                      const SizedBox(height: 12),

                      // Barra de busca e filtro
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _buscaController,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar chamado...',
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onChanged: provider.setBusca,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botão filtro com indicador manual (sem Badge nativo)
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.tune_rounded),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    onPressed: () => _abrirFiltros(context),
                                    tooltip: 'Filtros',
                                  ),
                                ),
                                if (provider.filtroBairro.isNotEmpty ||
                                    provider.filtroPrioridade.isNotEmpty ||
                                    provider.filtroStatus.isNotEmpty)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD32F2F),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Header lista
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          'Chamados (${provider.chamados.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de chamados
                provider.chamados.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 60,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum chamado encontrado',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final chamado = provider.chamados[index];
                            return ChamadoCard(
                              chamado: chamado,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: provider,
                                      child: DetalhesScreen(chamado: chamado),
                                    ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Excluir Chamado'),
                                    content: Text(
                                        'Deseja excluir "${chamado.titulo}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Excluir',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await provider.deletarChamado(chamado.id!);
                                }
                              },
                            );
                          },
                          childCount: provider.chamados.length,
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: context.read<ChamadoProvider>(),
                child: const CadastroScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Chamado'),
      ),
    );
  }
}
