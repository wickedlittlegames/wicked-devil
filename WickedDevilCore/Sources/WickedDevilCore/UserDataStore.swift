import Foundation

/// Abstraction over the key/value store that backs `User`.
///
/// The original talked to `NSUserDefaults` directly from `User.m`. Hiding it
/// behind a protocol lets the app use `UserDefaults` while tests use
/// `InMemoryUserDataStore`.
public protocol UserDataStore: AnyObject {
    func bool(forKey key: String) -> Bool
    func integer(forKey key: String) -> Int
    func string(forKey key: String) -> String?
    func intArray(forKey key: String) -> [Int]?
    func intMatrix(forKey key: String) -> [[Int]]?

    func set(_ value: Bool, forKey key: String)
    func set(_ value: Int, forKey key: String)
    func set(_ value: String?, forKey key: String)
    func set(_ value: [Int], forKey key: String)
    func set(_ value: [[Int]], forKey key: String)

    /// Equivalent of `[udata objectForKey:] != nil`, used by the original to
    /// decide whether a defaults section needed creating.
    func hasValue(forKey key: String) -> Bool
    func removeValue(forKey key: String)
    /// Equivalent of `[udata synchronize]`.
    func synchronize()
}

/// `UserDefaults`-backed store, matching the original persistence.
public final class UserDefaultsUserDataStore: UserDataStore {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }

    public func integer(forKey key: String) -> Int { defaults.integer(forKey: key) }

    public func string(forKey key: String) -> String? { defaults.string(forKey: key) }

    public func intArray(forKey key: String) -> [Int]? {
        defaults.array(forKey: key) as? [Int]
    }

    public func intMatrix(forKey key: String) -> [[Int]]? {
        defaults.array(forKey: key) as? [[Int]]
    }

    public func set(_ value: Bool, forKey key: String) { defaults.set(value, forKey: key) }

    public func set(_ value: Int, forKey key: String) { defaults.set(value, forKey: key) }

    public func set(_ value: String?, forKey key: String) {
        if let value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    public func set(_ value: [Int], forKey key: String) { defaults.set(value, forKey: key) }

    public func set(_ value: [[Int]], forKey key: String) { defaults.set(value, forKey: key) }

    public func hasValue(forKey key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }

    public func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    public func synchronize() {
        defaults.synchronize()
    }
}

/// In-memory store for tests and previews.
public final class InMemoryUserDataStore: UserDataStore {
    private enum Value {
        case bool(Bool)
        case int(Int)
        case string(String)
        case intArray([Int])
        case intMatrix([[Int]])
    }

    private var storage: [String: Value] = [:]
    /// Number of times `synchronize()` was called, handy in tests.
    public private(set) var synchronizeCount = 0

    public init() {}

    public func bool(forKey key: String) -> Bool {
        switch storage[key] {
        case .bool(let value): return value
        case .int(let value): return value != 0
        default: return false
        }
    }

    public func integer(forKey key: String) -> Int {
        switch storage[key] {
        case .int(let value): return value
        case .bool(let value): return value ? 1 : 0
        default: return 0
        }
    }

    public func string(forKey key: String) -> String? {
        if case .string(let value) = storage[key] { return value }
        return nil
    }

    public func intArray(forKey key: String) -> [Int]? {
        if case .intArray(let value) = storage[key] { return value }
        return nil
    }

    public func intMatrix(forKey key: String) -> [[Int]]? {
        if case .intMatrix(let value) = storage[key] { return value }
        return nil
    }

    public func set(_ value: Bool, forKey key: String) { storage[key] = .bool(value) }

    public func set(_ value: Int, forKey key: String) { storage[key] = .int(value) }

    public func set(_ value: String?, forKey key: String) {
        if let value {
            storage[key] = .string(value)
        } else {
            storage[key] = nil
        }
    }

    public func set(_ value: [Int], forKey key: String) { storage[key] = .intArray(value) }

    public func set(_ value: [[Int]], forKey key: String) { storage[key] = .intMatrix(value) }

    public func hasValue(forKey key: String) -> Bool { storage[key] != nil }

    public func removeValue(forKey key: String) { storage[key] = nil }

    public func synchronize() { synchronizeCount += 1 }
}
