class AppConstants {
  // Categorias
  static const List<String> categorias = [
    'Buraco na Rua',
    'Enchente',
    'Falta de Iluminação',
    'Lixo Acumulado',
    'Árvore Caída',
    'Acidente',
    'Vazamento de Água',
    'Outros',
  ];

  // Prioridades
  static const List<String> prioridades = [
    'Baixa',
    'Média',
    'Alta',
    'Crítica',
  ];

  // Status
  static const List<String> statusList = [
    'Aberto',
    'Em Andamento',
    'Concluído',
  ];

  // Bairros (exemplo)
  static const List<String> bairros = [
    'Centro',
    'Manaíra',
    'Tambaú',
    'Cabo Branco',
    'Altiplano',
    'Expedicionários',
    'Cristo',
    'Torre',
    'Bancários',
    'Mangabeira',
    'Valentina',
    'Outro',
  ];

  // Limite de chamados críticos para alerta
  static const int limiteAlertaCritico = 5;
}
