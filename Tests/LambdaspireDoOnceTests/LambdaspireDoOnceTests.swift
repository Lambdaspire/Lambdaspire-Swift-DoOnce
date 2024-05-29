
import LambdaspireAbstractions
import LambdaspireDependencyResolution

import XCTest
@testable import LambdaspireDoOnce

final class LambdaspireDoOnceTests: XCTestCase {
    
    func testDoOnceExecutorDoesIndeedDoOnceOnlyPerStorage() async throws {
        
        let serviceLocator: ServiceLocator = .init()
        
        let counter: Counter = .init()
        serviceLocator.register(counter)
        
        let userDefaultsA: UserDefaults = .init(suiteName: "Test-A-\(UUID())")!
        let userDefaultsB: UserDefaults = .init(suiteName: "Test-B-\(UUID())")!
        
        let storageA: UserDefaultsDoOnceStorage = .init(userDefaultsA)
        let storageB: UserDefaultsDoOnceStorage = .init(userDefaultsB)
        
        let executorA: DoOnceExecutor = .init(resolver: serviceLocator, storage: storageA)
        let executorB: DoOnceExecutor = .init(resolver: serviceLocator, storage: storageB)
        
        XCTAssertEqual(counter.count, 0)
        
        await executorA.execute(IncrementCountTask.self)
        await executorA.execute(IncrementCountTask.self)
        await executorA.execute(IncrementCountTask.self)
        
        XCTAssertEqual(counter.count, 1)
        
        await executorB.execute(IncrementCountTask.self)
        await executorB.execute(IncrementCountTask.self)
        await executorB.execute(IncrementCountTask.self)
        
        XCTAssertEqual(counter.count, 2)
        
        await executorA.execute("IncrementCountTask") { counter.increment() }
        
        XCTAssertEqual(counter.count, 2)
        
        await executorB.execute("IncrementCountTask") { counter.increment() }
        
        XCTAssertEqual(counter.count, 2)
        
        await executorA.execute("IncrementCountTask-\(UUID())") { counter.increment() }
        
        XCTAssertEqual(counter.count, 3)
        
        await executorB.execute("IncrementCountTask-\(UUID())") { counter.increment() }
        
        XCTAssertEqual(counter.count, 4)
        
        await storageA.clear()
        await storageB.clear()
    }
}

class Counter {
    var count: Int = 0
    
    func increment() {
        count += 1
    }
}

class IncrementCountTask : DoOnceTask {
    static func `do`(_ resolver: any DependencyResolver) async {
        resolver.resolve(Counter.self).increment()
    }
}
