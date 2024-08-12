
import LambdaspireAbstractions

public actor DoOnceExecutor : Resolvable {
    
    private let scope: DependencyResolutionScope
    private let storage: DoOnceStorage
    
    public init(scope: DependencyResolutionScope, storage: DoOnceStorage) {
        self.scope = scope
        self.storage = storage
    }
    
    public init(scope: any DependencyResolutionScope) {
        self.init(scope: scope, storage: scope.resolve())
    }
    
    public func execute<T: DoOnceTask>(_ t: T.Type) async {
        await execute(.init(describing: T.self)) { scope in
            await (scope.resolve() as T).run()
        }
    }
    
    public func execute(_ key: String, _ action: (DependencyResolutionScope) async -> Void) async {
        Log.debug("Task with key \(key) might be done if it hasn't already been done once.")
        
        if await storage.isDone(key) {
            Log.debug("Task with key \(key) was not done as it has already been done once.")
            return
        }
        
        await action(scope)
        
        Log.debug("Task with key \(key) was done once.")
        
        await storage.markAsDone(key)
        
        Log.debug("Task with key \(key) was marked as done so that it is not done more than once.")
    }
}
