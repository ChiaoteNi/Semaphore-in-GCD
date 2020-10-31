//
//  GroupDemoVC.swift
//  SemaphoreDemo
//
//  Created by 倪僑德 on 2020/10/25.
//  Copyright © 2020 倪僑德. All rights reserved.
//

import UIKit

final class ForceUpdateDemoVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Action functions.
extension ForceUpdateDemoVC {
    
    @IBAction private func checkisForceUpdateNeeded() {
        checkNeedUpdate()
    }
}

// MARK: - Private functions.
extension ForceUpdateDemoVC {
    
    private func checkNeedUpdate() {
        clearText()
        
        let semaphore: DispatchSemaphore = .init(value: 0)
        
        var forceUpdateVersion: String?
        let currentAppVersion: String = self.getCurrentAppVersion()
        
        // 情境: 強更機制，同時比較API回的強更版號，以及appStore回來的可下載版號
        //      這邊刻意讓她需先比較完強更版號，再來比較appStore版本號，來顯示異步任務但需有順序性的情境
        
        self.printText("local version = " + currentAppVersion)
        
        StubNetworkService().getVersionFromAPI { [weak self] appVersion in
            guard let self = self else { return }
            self.printText("api version = " + appVersion)
            
            if self.checkIsVersionLower(target: currentAppVersion, compareWith: appVersion) {
                forceUpdateVersion = appVersion
            }
            semaphore.signal()
        }
        
        StubNetworkService().getVersionFromAppStore { [weak self] appVersion in
            guard let self = self else { return }
            self.printText("appStore version = " + appVersion)
            
            semaphore.wait()
            self.printText("Start compare forceUpdateVersion with app version from appStore api.")
            
            guard let forceUpdateVersion = forceUpdateVersion,
                !self.checkIsVersionLower(target: appVersion, compareWith: forceUpdateVersion) else { return }
            
            self.updateApp()
        }
    }
    
    private func getCurrentAppVersion() -> String {
        return "1.2.1"
    }
    
    private func checkIsVersionLower(target: String, compareWith: String) -> Bool {
        
        let result = target.compare(
            compareWith,
            options: .numeric,
            range: nil,
            locale: nil
        )
        
        switch result {
        case .orderedSame, .orderedDescending:
            return false
        case .orderedAscending:
            return true
        }
    }
    
    private func updateApp() {
        printText("Start to update App!")
    }
}

// MARK: - Stub API
fileprivate final class StubNetworkService {
    
    func getVersionFromAppStore(then handler: @escaping (_ appVersion: String) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
            handler("1.2.3")
        }
    }
    
    func getVersionFromAPI(then handler: @escaping (_ appVersion: String) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            handler("1.2.2")
        }
    }
}
