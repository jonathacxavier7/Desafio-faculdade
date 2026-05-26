class Validators {
  static String? validarTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Título deve ter ao menos 3 caracteres';
    }
    return null;
  }

  static String? validarDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrição não pode ser vazia';
    }
    if (value.trim().length < 10) {
      return 'Descrição deve ter ao menos 10 caracteres';
    }
    return null;
  }

  static String? validarBairro(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bairro não pode ser vazio';
    }
    return null;
  }

  static String? validarResponsavel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Responsável é obrigatório';
    }
    return null;
  }

  static String? validarCategoria(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecione uma categoria';
    }
    return null;
  }

  static String? validarPrioridade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selecione uma prioridade';
    }
    return null;
  }
}
