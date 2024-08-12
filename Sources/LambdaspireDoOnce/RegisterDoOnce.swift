
import Foundation
import LambdaspireAbstractions

public extension DependencyRegistry {
    func doOnce() -> DoOnceRegistrator {
        .init(registry: self)
    }
}

public class DoOnceRegistrator {
    
    private let registry: any DependencyRegistry
    
    init(registry: any DependencyRegistry) {
        self.registry = registry
    }
    
    @discardableResult public func standardExecutor() -> Self {
        registry.singleton { DoOnceExecutor(scope: $0, storage: $0.resolve()) }
        return self
    }
    
    @discardableResult public func storage<T: DoOnceStorage & Resolvable>(_ : T.Type) -> Self {
        registry.singleton(DoOnceStorage.self, assigned(T.self))
        return self
    }
    
    @discardableResult public func task<T: DoOnceTask & Resolvable>(_ : T.Type) -> Self {
        registry.transient(T.self)
        return self
    }
    
    public func standard(
        userDefaults: UserDefaults = .standard,
        tasks: [any (DoOnceTask & Resolvable).Type]) {
            standardExecutor()
            registry.singleton(DoOnceStorage.self) { UserDefaultsDoOnceStorage(userDefaults) }
            tasks.forEach { task($0) }
        }
}
