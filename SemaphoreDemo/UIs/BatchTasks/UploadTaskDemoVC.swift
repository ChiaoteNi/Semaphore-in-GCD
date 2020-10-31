//
//  LimitRunTask.swift
//  SemaphoreDemo
//
//  Created by 倪僑德 on 2020/10/25.
//  Copyright © 2020 倪僑德. All rights reserved.
//

import UIKit

final class UploadTaskDemoVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Action functions
extension UploadTaskDemoVC {
    
    @IBAction private func startFakeUploadFiles() {
        clearText()
        printText("Start uploading 30 media files in 5 parallelism uploads.")
        
        // 情境: 30個併發上傳任務，但限制同時間僅執行5個
        
        let dispatch: DispatchSemaphore = .init(value: 5)
        
        DispatchQueue.global(qos: .background).async {
            for i in 0 ..< 30 {
                let fileName = "media_\(i)"
                
                dispatch.wait()
                
                self.uploadFile(with: fileName) { [weak self] fileName in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.printText("\nmedia_\(i) uploaded")
                    }
                    dispatch.signal()
                }
            }
        }
    }
}

// MARK: - Private functions
extension UploadTaskDemoVC {
    
    private func uploadFile(with fileName: String, then handler: @escaping (_ fileName: String) -> Void) {
        StubNetworkService().uploadFile(with: fileName) { fileName in
            handler(fileName)
        }
    }
}

// MARK: - Stub API
fileprivate final class StubNetworkService {
    
    func uploadFile(with fileName: String, then handler: @escaping (_ fileName: String) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
            handler(fileName)
        }
    }
}
