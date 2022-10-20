import Foundation
import Combine

extension ReadStorable {
    func getNext()  -> AnyPublisher<T, Error> {
        return self
            .objectDidChange
            .map { _ in self.state }
            .prefix(1)
            .setFailureType(to: Error.self)
            .flatMap({ state -> AnyPublisher<T, Error> in
                switch state {
                case .loaded(let value), .refreshing(let value):
                    return Result.Publisher(.success(value)).eraseToAnyPublisher()
                case .errored(let error):
                    return Result.Publisher(.failure(error)).eraseToAnyPublisher()
                case .loading:
                    return self.getNext()
                case .initial:
                    self.fetch()
                    return self.getNext()
                }
            })
            .eraseToAnyPublisher()
    }
}
