
import LambdaspireAbstractions

public actor DoOnceExecutor {
    
    private let resolver: DependencyResolver
    private let storage: DoOnceStorage
    
    public init(resolver: DependencyResolver, storage: DoOnceStorage) {
        self.resolver = resolver
        self.storage = storage
    }
    
    public func execute<T: DoOnceTask>(_ t: T.Type) async {
        await execute(.init(describing: T.self)) {
            await T.do(resolver)
        }
    }
    
    public func execute(_ key: String, _ action: () async -> Void) async {
        Log.debug("Task with key \(key) might be done if it hasn't already been done once.")
        
        if await storage.isDone(key) {
            Log.debug("Task with key \(key) was not done as it has already been done once.")
            return
        }
        
        await action()
        
        Log.debug("Task with key \(key) was done once.")
        
        await storage.markAsDone(key)
        
        Log.debug("Task with key \(key) was marked as done so that it is not done more than once.")
    }
}
