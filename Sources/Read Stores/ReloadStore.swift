//
//  File.swift
//  
//
//  Created by Narek Mailian on 2022-10-07.
//

import Foundation
import Store
import Combine

public extension ReadStorable {
    func reloadOn(_ closure: @escaping (Self.T) -> Date?) -> ReadStore<Self.T> {
        let pinger = CurrentValueSubject<Void, Never>(())
        
        let publish = PublishedStore(pinger.eraseToAnyPublisher())
        
        return ParallelReadStore(publish, self) { _, b in
            if let date = closure(b) {
                let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
                    pinger.send(())
                }
                RunLoop.main.add(timer, forMode: .common)
            }
            
            return b

        }
        .eraseToAnyReadStore()
    }
    
    func reloadEvery(timeInterval: TimeInterval) -> ReadStore<Self.T> {
        let timer = Timer.TimerPublisher(interval: timeInterval, runLoop: .main, mode: .default)
            .autoconnect()
            .eraseToAnyPublisher()

        let timerStore = PublishedStore(timer).eraseToAnyReadStore()
        
        return ParallelReadStore(timerStore, self) { _, b in
            return b
        }
        .eraseToAnyReadStore()
    }
}
