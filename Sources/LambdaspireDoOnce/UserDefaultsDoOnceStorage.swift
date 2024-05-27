
import Foundation

public class UserDefaultsDoOnceStorage : DoOnceStorage {
    
    private let userDefaults: UserDefaults
    
    public init(_ userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func isDone<T>(_ t: T.Type) async -> Bool where T : DoOnceTask {
        userDefaults.bool(forKey: key(t))
    }
    
    public func markAsDone<T>(_ t: T.Type) async where T : DoOnceTask {
        userDefaults.setValue(true, forKey: key(t))
    }
    
    public func clear<T>(_ t: T.Type) async where T : DoOnceTask {
        userDefaults.removeObject(forKey: key(t))
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
    
    private func key<T>(_ : T.Type) -> String { "\(keyPrefix).\(String(describing: T.self))" }
}
