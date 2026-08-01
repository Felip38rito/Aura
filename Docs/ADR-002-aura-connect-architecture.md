# AuraConnect — Plano de Implementação

## Filosofia
Swift puro, sem dependências externas. URLSession nativa, Codable, async/await, value types, protocols. Nada de bibliotecas third-party.

## Arquitetura

### 1. HTTPRequest — value type
```swift
public struct HTTPRequest: Sendable {
    public var method: HTTPMethod
    public var url: URL
    public var headers: [String: String]
    public var body: Data?
}
```

### 2. HTTPResponse — value type
```swift
public struct HTTPResponse: Sendable {
    public var statusCode: Int
    public var headers: [String: String]
    public var body: Data

    public func decode<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = .init()) throws -> T
}
```

### 3. HTTPMethod — enum
```swift
public enum HTTPMethod: String, Sendable {
    case get, post, put, patch, delete, head, options
}
```

### 4. AuraConnector — protocol (testabilidade)
```swift
public protocol AuraConnector: Sendable {
    func request(_ request: HTTPRequest) async throws -> HTTPResponse
    func download(_ request: HTTPRequest) async throws -> (URL, HTTPResponse)
}
```

### 5. AuraURLSessionConnector — classe final (produção)
```swift
public final class AuraURLSessionConnector: AuraConnector {
    private let session: URLSession
    private var middlewares: [AuraConnectorMiddleware]

    public init(session: URLSession = .shared, middlewares: [AuraConnectorMiddleware] = [])
    public func register(_ middleware: AuraConnectorMiddleware)

    // AuraConnector
    public func request(_ request: HTTPRequest) async throws -> HTTPResponse
    public func download(_ request: HTTPRequest) async throws -> (URL, HTTPResponse)
}
```

### 6. AuraConnectorMiddleware — protocol (extensibilidade)
```swift
public protocol AuraConnectorMiddleware: Sendable {
    func before(request: HTTPRequest) async throws -> HTTPRequest
    func after(response: HTTPResponse) async throws -> HTTPResponse
}
```

### 7. RequestBuilder — construção fluente
```swift
public struct RequestBuilder {
    public init() {}
    public func with(method: HTTPMethod) -> Self
    public func with(url: String) -> Self
    public func with(path: String) -> Self
    public func with(header: String, value: String) -> Self
    public func with(headers: [String: String]) -> Self
    public func with(body: some Encodable, encoder: JSONEncoder = .init()) -> Self
    public func with(body: Data) -> Self
    public func build() throws -> HTTPRequest
}
```

### 8. Middlewares built-in (opcionais, módulo separado ou futuros)
- `CodableMiddleware` — decode automático via plugin
- `LoggingMiddleware` — print/log de requests
- `RetryMiddleware` — retry com backoff
- `AuthMiddleware` — token injection (futuro, OIDC etc)

## Fluxo de execução

```
RequestBuilder → HTTPRequest → AuraURLSessionConnector.request()
                                    │
                                    ▼
                            [before] middleware chain
                                    │
                                    ▼
                            URLSession.data(for:)
                                    │
                                    ▼
                            [after] middleware chain (reversed)
                                    │
                                    ▼
                            HTTPResponse
```

## Estrutura de arquivos

```
Sources/AuraConnect/
├── AuraConnect.swift          — namespace, re-exports
├── HTTPMethod.swift
├── HTTPRequest.swift
├── HTTPResponse.swift
├── AuraConnector.swift        — protocol
├── AuraURLSessionConnector.swift
├── AuraConnectorMiddleware.swift
└── RequestBuilder.swift

Tests/AuraConnectTests/
├── HTTPRequestTests.swift
├── HTTPResponseTests.swift
├── AuraURLSessionConnectorTests.swift
└── RequestBuilderTests.swift
```

## O que NÃO fazer agora
- Não adicionar dependências externas (Alamofire, Moya, etc.)
- Não implementar cache, OIDC, gzip, criptografia — entram como middleware depois
- Não acoplar ao AuraKernel — AuraConnect é módulo independente
- Não usar @MainActor — networking roda em background
