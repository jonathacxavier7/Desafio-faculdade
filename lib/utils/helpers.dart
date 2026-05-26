import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  static String formatarDataCurta(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  static String tempoDesdeAbertura(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inDays > 0) {
      return '${diferenca.inDays} dia(s) atrás';
    } else if (diferenca.inHours > 0) {
      return '${diferenca.inHours} hora(s) atrás';
    } else if (diferenca.inMinutes > 0) {
      return '${diferenca.inMinutes} min atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  static Color corPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Crítica':
        return const Color(0xFFD32F2F);
      case 'Alta':
        return const Color(0xFFF57C00);
      case 'Média':
        return const Color(0xFFF9A825);
      case 'Baixa':
        return const Color(0xFF388E3C);
      default:
        return Colors.grey;
    }
  }

  static Color corStatus(String status) {
    switch (status) {
      case 'Aberto':
        return const Color(0xFF1565C0);
      case 'Em Andamento':
        return const Color(0xFFF57C00);
      case 'Concluído':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  static IconData iconCategoria(String categoria) {
    switch (categoria) {
      case 'Buraco na Rua':
        return Icons.warning_rounded;
      case 'Enchente':
        return Icons.water_damage_rounded;
      case 'Falta de Iluminação':
        return Icons.lightbulb_outline_rounded;
      case 'Lixo Acumulado':
        return Icons.delete_outline_rounded;
      case 'Árvore Caída':
        return Icons.park_rounded;
      case 'Acidente':
        return Icons.car_crash_rounded;
      case 'Vazamento de Água':
        return Icons.water_drop_outlined;
      default:
        return Icons.report_problem_rounded;
    }
  }
}
