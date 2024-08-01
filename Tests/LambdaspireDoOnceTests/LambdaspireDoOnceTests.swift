
import LambdaspireAbstractions
import LambdaspireDependencyResolution

import XCTest
@testable import LambdaspireDoOnce

final class LambdaspireDoOnceTests: XCTestCase {
    
    func testDoOnceExecutorDoesIndeedDoOnceOnlyPerStorage() async throws {
        
        let builder: ContainerBuilder = .init()
        
        builder.singleton(Counter.self)
        builder.transient(IncrementCountTask.self)
        
        let container = builder.build()
        
        let counter: Counter = container.resolve()
        
        let userDefaultsA: UserDefaults = .init(suiteName: "Test-A-\(UUID())")!
        let userDefaultsB: UserDefaults = .init(suiteName: "Test-B-\(UUID())")!
        
        let storageA: UserDefaultsDoOnceStorage = .init(userDefaultsA)
        let storageB: UserDefaultsDoOnceStorage = .init(userDefaultsB)
        
        let executorA: DoOnceExecutor = .init(scope: container, storage: storageA)
        let executorB: DoOnceExecutor = .init(scope: container, storage: storageB)
        
        XCTAssertEqual(counter.count, 0)
        
        await executorA.execute(IncrementCountTask.self)
        await executorA.execute(IncrementCountTask.self)
        await executorA.execute(IncrementCountTask.self)
        
        XCTAssertEqual(counter.count, 1)
        
        await executorB.execute(IncrementCountTask.self)
        await executorB.execute(IncrementCountTask.self)
        await executorB.execute(IncrementCountTask.self)
        
        XCTAssertEqual(counter.count, 2)
        
        await executorA.execute("IncrementCountTask") { _ in counter.increment() }
        
        XCTAssertEqual(counter.count, 2)
        
        await executorB.execute("IncrementCountTask") { s in s.resolve(Counter.self).increment() }
        
        XCTAssertEqual(counter.count, 2)
        
        await executorA.execute("IncrementCountTask-\(UUID())") { _ in counter.increment() }
        
        XCTAssertEqual(counter.count, 3)
        
        await executorB.execute("IncrementCountTask-\(UUID())") { s in s.resolve(Counter.self).increment() }
        
        XCTAssertEqual(counter.count, 4)
        
        await executorB.execute("IncrementCountTask-\(UUID())") { s in s.resolve(Counter.self).increment() }
        
        XCTAssertEqual(counter.count, 5)
        
        await storageA.clear()
        await storageB.clear()
    }
}

@Resolvable
class Counter {
    var count: Int = 0
    
    func increment() {
        count += 1
    }
}

@Resolvable
class IncrementCountTask : DoOnceTask {
    
    private let counter: Counter
    
    init(counter: Counter) {
        self.counter = counter
    }
    
    func run() async {
        counter.increment()
    }
}
