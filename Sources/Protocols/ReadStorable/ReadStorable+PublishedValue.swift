import Foundation
import Combine

public extension ReadStorable {
    func publishedValue() -> AnyPublisher<T, Error> {
        fetchIfNeeded()
        
        switch self.state {
        case .loaded(let value), .refreshing(let value):
            return Result.Publisher(.success(value)).eraseToAnyPublisher()
        default:
            break
        }
        
        return self.getNext()
    }
}
