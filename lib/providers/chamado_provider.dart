import 'package:flutter/foundation.dart';
import '../models/chamado_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class ChamadoProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Chamado> _chamados = [];
  String _busca = '';
  String _filtroBairro = '';
  String _filtroPrioridade = '';
  String _filtroStatus = '';
  bool _carregando = false;
  String? _erro;

  // Getters
  bool get carregando => _carregando;
  String? get erro => _erro;
  String get busca => _busca;
  String get filtroBairro => _filtroBairro;
  String get filtroPrioridade => _filtroPrioridade;
  String get filtroStatus => _filtroStatus;

  List<Chamado> get chamados {
    List<Chamado> resultado = List.from(_chamados);

    if (_busca.isNotEmpty) {
      resultado = resultado
          .where((c) => c.titulo.toLowerCase().contains(_busca.toLowerCase()))
          .toList();
    }
    if (_filtroBairro.isNotEmpty) {
      resultado = resultado.where((c) => c.bairro == _filtroBairro).toList();
    }
    if (_filtroPrioridade.isNotEmpty) {
      resultado =
          resultado.where((c) => c.prioridade == _filtroPrioridade).toList();
    }
    if (_filtroStatus.isNotEmpty) {
      resultado = resultado.where((c) => c.status == _filtroStatus).toList();
    }

    return resultado;
  }

  // Estatísticas
  int get totalChamados => _chamados.length;
  int get chamadosAbertos =>
      _chamados.where((c) => c.status == 'Aberto').length;
  int get chamadosEmAndamento =>
      _chamados.where((c) => c.status == 'Em Andamento').length;
  int get chamadosConcluidos =>
      _chamados.where((c) => c.status == 'Concluído').length;
  int get chamadosCriticos =>
      _chamados.where((c) => c.prioridade == 'Crítica').length;

  // Regra 2: Alerta se mais de 5 chamados críticos
  bool get alertaCritico =>
      chamadosCriticos > AppConstants.limiteAlertaCritico;

  Future<void> carregarChamados() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _chamados = await _dbService.buscarTodos();
    } catch (e) {
      _erro = 'Erro ao carregar chamados: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<String?> adicionarChamado(Chamado chamado) async {
    // Regra 3: Não permitir título repetido
    final existe = await _dbService.tituloExiste(chamado.titulo);
    if (existe) {
      return 'Já existe um chamado com esse título';
    }

    try {
      final id = await _dbService.inserir(chamado);
      final novo = chamado.copyWith(id: id);
      _chamados.add(novo);
      _ordenarChamados();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao salvar chamado: $e';
    }
  }

  Future<String?> atualizarChamado(Chamado chamado) async {
    // Regra 6: Chamados concluídos não podem ser editados
    final original = _chamados.firstWhere((c) => c.id == chamado.id);
    if (original.status == 'Concluído') {
      return 'Chamados concluídos não podem ser editados';
    }

    // Regra 3: Não permitir título repetido
    final existe =
        await _dbService.tituloExiste(chamado.titulo, excluirId: chamado.id);
    if (existe) {
      return 'Já existe um chamado com esse título';
    }

    try {
      await _dbService.atualizar(chamado);
      final index = _chamados.indexWhere((c) => c.id == chamado.id);
      if (index != -1) {
        _chamados[index] = chamado;
        _ordenarChamados();
        notifyListeners();
      }
      return null;
    } catch (e) {
      return 'Erro ao atualizar chamado: $e';
    }
  }

  Future<String?> atualizarStatus(int id, String novoStatus) async {
    final chamado = _chamados.firstWhere((c) => c.id == id);

    // Regra 6: Chamados concluídos não podem ser editados
    if (chamado.status == 'Concluído') {
      return 'Chamados concluídos não podem ser editados';
    }

    final atualizado = chamado.copyWith(status: novoStatus);
    return await atualizarChamado(atualizado);
  }

  Future<void> deletarChamado(int id) async {
    await _dbService.deletar(id);
    _chamados.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void setBusca(String value) {
    _busca = value;
    notifyListeners();
  }

  void setFiltroBairro(String value) {
    _filtroBairro = value;
    notifyListeners();
  }

  void setFiltroPrioridade(String value) {
    _filtroPrioridade = value;
    notifyListeners();
  }

  void setFiltroStatus(String value) {
    _filtroStatus = value;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _filtroBairro = '';
    _filtroPrioridade = '';
    _filtroStatus = '';
    notifyListeners();
  }

  // Regra 1: Chamados críticos e alta prioridade no topo
  void _ordenarChamados() {
    const ordem = {'Crítica': 0, 'Alta': 1, 'Média': 2, 'Baixa': 3};
    _chamados.sort((a, b) {
      final pa = ordem[a.prioridade] ?? 4;
      final pb = ordem[b.prioridade] ?? 4;
      if (pa != pb) return pa.compareTo(pb);
      return b.data.compareTo(a.data);
    });
  }

  bool chamadoConcluido(int id) {
    try {
      return _chamados.firstWhere((c) => c.id == id).status == 'Concluído';
    } catch (_) {
      return false;
    }
  }
}
