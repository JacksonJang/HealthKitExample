//
//  ViewController.swift
//  HealthKitExample
//
//  Created by 장효원 on 4/14/24.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        requestPermissions() { [weak self] bool in
            if bool {
                self?.readStepCount() { totalCount in
                    print("totalCount : \(totalCount)")
                }
            }
        }
    }
}

extension ViewController {
    // 권한 요청
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes = Set([
            HKQuantityType(.stepCount)
        ])

        let writeTypes = Set<HKSampleType>()

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { bool, error in
            completion(bool)
        }
    }
    
    // 걸음 수
    func readStepCount(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType(.stepCount)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else {
                completion(0)
                return
            }

            let totalSteps = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) }
            DispatchQueue.main.async {
                completion(totalSteps)
            }
        }
        healthStore.execute(query)
    }

}

