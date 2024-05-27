
public protocol DoOnceStorage {
    func isDone<T: DoOnceTask>(_ t: T.Type) async -> Bool
    func markAsDone<T: DoOnceTask>(_ t: T.Type) async
    func clear<T: DoOnceTask>(_ t: T.Type) async
    func clear() async
}
