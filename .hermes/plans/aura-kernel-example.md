## Plano: Exemplo AuraKernel

### O que vamos construir

Substituir o `AuraExampleApp.swift` atual por um app que demonstra o AuraKernel:

1. **LoggingPlugin** — plugin que loga eventos do kernel (boot, scene active, background)
2. **ConfigurationPlugin** — plugin que carrega um config JSON no boot e expõe via kernel
3. **AppDelegate/SceneDelegate** — usando AuraSceneKernel, registra plugins, boota
4. **ContentView** — tela que mostra o estado dos plugins (logado, config carregada)

### Arquivos

- `Tuist/Sources/Plugins/LoggingPlugin.swift`
- `Tuist/Sources/Plugins/ConfigurationPlugin.swift`
- `Tuist/Sources/AuraExampleApp.swift` — substituído

### Não fazer
- Não modificar Package.swift
- Não modificar fontes do AuraKernel
- Não adicionar dependências externas
