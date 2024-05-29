
import SwiftUI
import LambdaspireAbstractions

public extension View {
    
    func doOnce<T: DoOnceTask>(_ t: T.Type) -> some View {
        modifier(DoOnceModifier<T>())
    }
    
    func doOnce(configuration: DoOnceConfiguration) -> some View {
        environment(\.doOnceExecutor, configuration.executor)
    }
}

public struct DoOnceConfiguration {
    
    public var executor: DoOnceExecutor
    
    public init(executor: DoOnceExecutor) {
        self.executor = executor
    }
}

struct DoOnceModifier<T: DoOnceTask> : ViewModifier {
    
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
    static let defaultValue: DoOnceExecutor = .init(resolver: FailResolver(), storage: FailStorage())
}

// Could enforce reasonable defaults, but it woudl require a package dependency for a concrete DependencyResolver.

class FailResolver : DependencyResolver {
    func resolve<T>() -> T { fatalError("Please use a real DependencyResolver.") }
    func resolve<T>(_ t: T.Type) -> T { fatalError("Please use a real DependencyResolver.") }
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
