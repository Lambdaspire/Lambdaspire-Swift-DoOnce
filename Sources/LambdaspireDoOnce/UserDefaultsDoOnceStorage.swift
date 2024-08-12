
import Foundation
import LambdaspireAbstractions

public class UserDefaultsDoOnceStorage : DoOnceStorage, Resolvable {
    
    private let userDefaults: UserDefaults
    
    public init(_ userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public required convenience init(scope: any DependencyResolutionScope) {
        self.init()
    }
    
    public func isDone<T>(_ t: T.Type) async -> Bool where T : DoOnceTask {
        await isDone(fullKey(t))
    }
    
    public func isDone(_ key: String) async -> Bool {
        userDefaults.bool(forKey: fullKey(key))
    }
    
    public func markAsDone<T>(_ t: T.Type) async where T : DoOnceTask {
        await markAsDone(fullKey(t))
    }
    
    public func markAsDone(_ key: String) async {
        userDefaults.setValue(true, forKey: fullKey(key))
    }
    
    public func clear<T>(_ t: T.Type) async where T : DoOnceTask {
        await clear(fullKey(t))
    }
    
    public func clear(_ key: String) async {
        userDefaults.removeObject(forKey: fullKey(key))
    }
    
    public func clear() async {
        userDefaults
            .dictionaryRepresentation()
            .keys
            .filter { $0.hasPrefix("\(keyPrefix).")}
            .forEach { key in
                userDefaults.removeObject(forKey: key)
            }
    }
    
    private var keyPrefix: String = .init(describing: UserDefaultsDoOnceStorage.self)
    
    private func fullKey<T>(_ : T.Type) -> String { fullKey(String(describing: T.self)) }
    private func fullKey(_ key: String) -> String { "\(keyPrefix).\(key)" }
}
