import Foundation

enum UnwrapError: LocalizedError {
    case objectNotFound
    
    var errorDescription: String? {
        switch self {
        case .objectNotFound:
            return "Object not found"
        }
    }
}

public protocol Wrapping {
    associatedtype Wrapped
    func unwrapWithError() throws -> Wrapped
}

extension Optional: Wrapping {
    public func unwrapWithError() throws -> Wrapped {
        if let value = self {
            return value
        } else {
            throw UnwrapError.objectNotFound
        }
    }
}
