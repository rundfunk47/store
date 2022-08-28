import Foundation
import Combine

public extension ReadStorable {
    func value() async throws -> T {
        switch state {
        case .loaded(let value):
            return value
        default:
            break
        }
        
        fetchIfNeeded()
        
        var cancellable: AnyCancellable? = nil
        
        let value = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            cancellable = self.getNext().sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    continuation.resume(throwing: error)
                default:
                    break
                }
            }, receiveValue: { (value: T) in
                continuation.resume(returning: value)
            })
        }
        
        cancellable?.cancel()
        cancellable = nil
        
        return value
    }
}
