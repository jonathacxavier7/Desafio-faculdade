# SOS Cidade — Flutter App

## Pré-requisitos
- Flutter SDK >= 3.10.0
- Android Studio ou VS Code com extensão Flutter

## Como rodar

### 1. Instalar dependências
```bash
flutter pub get
```

### 2. Rodar no dispositivo/emulador
```bash
flutter run
```

### 3. Build release
```bash
flutter build apk --release
```

## Estrutura
```
lib/
├── main.dart               # Ponto de entrada
├── models/                 # Classe Chamado
├── providers/              # Gerenciamento de estado (Provider)
├── services/               # Banco de dados SQLite
├── screens/                # Telas: Dashboard, Cadastro, Detalhes
├── widgets/                # Componentes reutilizáveis
├── utils/                  # Constantes, validadores, helpers
└── theme/                  # Temas claro e escuro
```

## Dependências
| Pacote | Versão | Finalidade |
|--------|--------|------------|
| provider | ^6.1.2 | Gerenciamento de estado |
| sqflite | ^2.3.3 | Banco de dados local |
| path | ^1.9.0 | Caminhos de arquivo |
| intl | ^0.18.1 | Formatação de datas (pt_BR) |
