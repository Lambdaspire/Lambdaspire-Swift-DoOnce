
import SwiftUI
import LambdaspireAbstractions

public extension View {
    
    func doOnce<T: DoOnceTask>(_ t: T.Type) -> some View {
        modifier(DoOnceModifierWithType<T>())
    }
    
    func doOnce(_ key: String, _ action: @escaping (DependencyResolver) async -> Void) -> some View {
        modifier(DoOnceModifierWithStringKey(key: key, action: action))
    }
    
    func doOnce(configuration: DoOnceConfiguration) -> some View {
        environment(\.doOnceExecutor, configuration.executor)
    }
    
    func doOnce(from scope: any DependencyResolutionScope) -> some View {
        environment(\.doOnceExecutor, scope.resolve())
    }
}

public struct DoOnceConfiguration {
    
    public var executor: DoOnceExecutor
    
    public init(executor: DoOnceExecutor) {
        self.executor = executor
    }
}

struct DoOnceModifierWithStringKey : ViewModifier {
    
    var key: String
    var action: (DependencyResolver) async -> Void
    
    @Environment(\.doOnceExecutor) private var executor
    
    func body(content: Content) -> some View {
        content
            .task {
                await executor.execute(key, action)
            }
    }
}

struct DoOnceModifierWithType<T: DoOnceTask> : ViewModifier {
    
    @Environment(\.doOnceExecutor) private var executor
    
    func body(content: Content) -> some View {
        content
            .task {
                await executor.execute(T.self)
            }
    }
}

public extension EnvironmentValues {
    var doOnceExecutor: DoOnceExecutor {
        get { self[DoOnceExecutorKey.self] }
        set { self[DoOnceExecutorKey.self] = newValue }
    }
}

struct DoOnceExecutorKey : EnvironmentKey {
    static let defaultValue: DoOnceExecutor = .init(scope: FailScope(), storage: FailStorage())
}

// Could enforce reasonable defaults, but it would require a package dependency for a concrete DependencyResolver.

class FailScope : DependencyResolutionScope {
    
    var id: String { "" }
    
    func scope() -> any DependencyResolutionScope { self }
    
    func tryResolve<C>() -> C? { nil }
    
    func resolve<C>() -> C { fatalError() }
}

class FailStorage : DoOnceStorage {
    func isDone<T>(_ t: T.Type) async -> Bool where T : DoOnceTask { fatalError("Please use a real DoOnceStorage.") }
    func isDone(_ key: String) async -> Bool { fatalError("Please use a real DoOnceStorage.") }
    func markAsDone<T>(_ t: T.Type) async where T : DoOnceTask { fatalError("Please use a real DoOnceStorage.") }
    func markAsDone(_ key: String) async { fatalError("Please use a real DoOnceStorage.") }
    func clear<T>(_ t: T.Type) async where T : DoOnceTask { fatalError("Please use a real DoOnceStorage.") }
    func clear(_ key: String) async { fatalError("Please use a real DoOnceStorage.") }
    func clear() async { fatalError("Please use a real DoOnceStorage.") }
}
