
import LambdaspireAbstractions

public actor DoOnceExecutor {
    
    private let resolver: DependencyResolver
    private let storage: DoOnceStorage
    
    public init(resolver: DependencyResolver, storage: DoOnceStorage) {
        self.resolver = resolver
        self.storage = storage
    }
    
    public func execute<T: DoOnceTask>(_ t: T.Type) async {
        
        Log.debug("\(T.self) might be done if it hasn't already been done once.")
        
        if await storage.isDone(t) {
            Log.debug("\(T.self) was not done as it has already been done once.")
            return
        }
        
        await t.do(resolver)
        
        Log.debug("\(T.self) was done once.")
        
        await storage.markAsDone(t)
        
        Log.debug("\(T.self) was marked as done so that it is not done more than once.")
    }
}
