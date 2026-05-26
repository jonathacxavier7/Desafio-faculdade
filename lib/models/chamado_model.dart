class Chamado {
  int? id;
  String titulo;
  String descricao;
  String categoria;
  String prioridade;
  String bairro;
  String responsavel;
  String status;
  DateTime data;

  Chamado({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.status,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria,
      'prioridade': prioridade,
      'bairro': bairro,
      'responsavel': responsavel,
      'status': status,
      'data': data.toIso8601String(),
    };
  }

  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      prioridade: map['prioridade'],
      bairro: map['bairro'],
      responsavel: map['responsavel'],
      status: map['status'],
      data: DateTime.parse(map['data']),
    );
  }

  Chamado copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? categoria,
    String? prioridade,
    String? bairro,
    String? responsavel,
    String? status,
    DateTime? data,
  }) {
    return Chamado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      bairro: bairro ?? this.bairro,
      responsavel: responsavel ?? this.responsavel,
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }
}
