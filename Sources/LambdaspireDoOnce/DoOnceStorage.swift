
public protocol DoOnceStorage {
    func isDone<T: DoOnceTask>(_ t: T.Type) async -> Bool
    func isDone(_ key: String) async -> Bool
    func markAsDone<T: DoOnceTask>(_ t: T.Type) async
    func markAsDone(_ key: String) async
    func clear<T: DoOnceTask>(_ t: T.Type) async
    func clear(_ key: String) async
    func clear() async
}
