//
//  SimpleDemoVC.swift
//  SemaphoreDemo
//
//  Created by 倪僑德 on 2020/10/27.
//  Copyright © 2020 倪僑德. All rights reserved.
//

import UIKit

final class SimpleDemoVC: BaseVC {
    
    private var globalValue: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Action functions.
extension SimpleDemoVC {
    
    @IBAction private func runDemo() {
        clearText()
        
        runSerializeDemo()
//        runRaceConditionDemo()
    }
}

// MARK: - Private functions.
extension SimpleDemoVC {
    
    // MARK: Serialize Demo
    
    private func runSerializeDemo() {
        // 可以把 semaphore 設為 nil，看看未使用semaphore的情況
        let semaphore: DispatchSemaphore? = .init(value: 1) // nil
        
        print("🏵", with: semaphore)
        print("🔮", with: semaphore)
        print("🧩", with: semaphore)
    }
    
    private func print(_ text: String, with semaphore: DispatchSemaphore?) {
        semaphore?.wait()
        
        DispatchQueue.global().async {
            for i in 0 ..< 5 {
                self.printText(text + "\(i)")
            }
            semaphore?.signal()
        }
    }
    
    // MARK: Race Condition Demo
    
    private func runRaceConditionDemo() {
        globalValue = 0
        
        // 可以把 semaphore 設為 nil，看看未使用semaphore的情況
        let semaphore: DispatchSemaphore? = .init(value: 0) // nil
        
        self.increaseValue(with: semaphore)
        self.reduceValue(with: semaphore)
    }
    
    private func increaseValue(with semaphore: DispatchSemaphore?) {
        
        DispatchQueue.global(qos: .background).async {
            for _ in 0 ..< 10 {
                self.globalValue += 1
            }
            semaphore?.signal()
        }
        semaphore?.wait()
    }
    
    private func reduceValue(with semaphore: DispatchSemaphore?) {

        DispatchQueue.global(qos: .background).sync {
            for _ in 0 ..< 10 {
                self.globalValue -= 1
                self.printText("\(self.globalValue)")
            }
        }
    }
}
