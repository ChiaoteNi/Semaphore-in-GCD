//
//  TimeoutDemoVC.swift
//  SemaphoreDemo
//
//  Created by 倪僑德 on 2020/10/27.
//  Copyright © 2020 倪僑德. All rights reserved.
//

import UIKit

final class TimeoutDemoVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Action functions.
extension TimeoutDemoVC {
    
    @IBAction private func runDemo() {
        clearText()
        
        let semaphore: DispatchSemaphore = .init(value: 0)
        let waitingTime: DispatchTimeInterval = .seconds(2)
        
        // 情境: noraml api completion的任務 會等 timeout api 回來後才能進行，除非超過2秒
        
        StubNetworkService().callNormalAPI { [weak self] response in
            guard let self = self else { return }
            
            self.printText("Normal api is callback.")
            
            let result = semaphore.wait(timeout: .now() + waitingTime)
            self.printText("\(result)")
            
            self.printText("API done, start to do something.")
        }
        
        StubNetworkService().callTimeoutAPI { [weak self] response in
            guard let self = self else { return }
            
            self.printText("Timeout api is callback.")
            semaphore.signal()
        }
    }
}

// MARK: - Private functions.
extension TimeoutDemoVC {
    
}

// MARK: - Stub API
fileprivate final class StubNetworkService {
    
    func callNormalAPI(then handler: @escaping (_ appVersion: String) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            handler("1.2.3")
        }
    }
    
    func callTimeoutAPI(then handler: @escaping (_ appVersion: String) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            handler("1.2.2")
        }
    }
}
