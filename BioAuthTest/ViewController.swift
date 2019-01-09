//
//  ViewController.swift
//  BioAuthTest
//
//  Created by Thyeon on 07/01/2019.
//  Copyright © 2019 thhan. All rights reserved.
//

import UIKit
import LocalAuthentication
import Security

class ViewController: UIViewController {
    
    private static let serviceID = "BioAuthTest"
    private static let accountID = "penta"
    
    @IBOutlet weak var bioAuthSwitch: UISwitch!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var savePinNumberButton: UIButton!
    @IBOutlet weak var deletePinNumberButton: UIButton!
    @IBOutlet weak var getPinNumberButton: UIButton!
    
    private var isOnBioAuth: Bool = false
    private let maxPinNumberCount: Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hasData()
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        isOnBioAuth = sender.isOn
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender {
        case savePinNumberButton:
            saveData()
        case deletePinNumberButton:
            deleteKeychainData()
            setButtons(isEnable: false)
        case getPinNumberButton:
            getPinNumber()
        default: return
        }
    }
    
    private func saveData() {
        if let pinNumber = inputTextField.text,
            pinNumber.count == 6 {
            saveKeychainData(value: pinNumber)
            setButtons(isEnable: true)
            inputTextField.resignFirstResponder()
        }
    }
    
    private func hasData() {
        getKeychainData() != nil ? setButtons(isEnable: true) : setButtons(isEnable: false)
    }
    
    private func getPinNumber() {
        var value = ""
        var status = ""
        
        if isOnBioAuth {
            getKeychainDataByBioAuth()
        } else {
            if let keychainData = getKeychainData() {
                value = keychainData
                status = "success keychain"
            } else {
                value = "null"
                status = "fail"
            }
        }
        
        setLabels(status: status, data: value)
    }
    
    private func getKeychainDataByBioAuth() {
        let authContext = LAContext()
        var error: NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: "생체인식 해주세요.",
                                       reply: { success, error in
                                        
                                        if success {
                                            DispatchQueue.main.async {
                                                if let keychainData = self.getKeychainData() {
                                                    self.setLabels(status: "success bio auth", data: keychainData)
                                                } else {
                                                    self.setLabels(status: "fail", data: "null")
                                                }
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                if let errorMsg = self.didUserAuthenticationFaild(error: error) {
                                                    self.setLabels(status: "error", data: errorMsg)
                                                }
                                            }
                                        }
            })
        } else {
            if let errorMsg = self.didUserAuthenticationFaild(error: error) {
                self.setLabels(status: "error", data: errorMsg)
            }
        }
    }
    
    func didUserAuthenticationFaild(error: Error?) -> String? {
        guard let e = error else { return nil }
        switch e {
        case LAError.authenticationFailed:
            return "failed"
        case LAError.userCancel:
            return "canceled by user"
        case LAError.userFallback:
            return "user wants to enter password"
        case LAError.systemCancel:
            return "canceled by system"
        case LAError.passcodeNotSet:
            return "passcodeNotSet"
        default:
            return "TouchID is not available"
        }
    }
    
    private func getKeychainData() -> String? {
        return Keychain.get(service: ViewController.serviceID, account: ViewController.accountID)
    }
    
    private func saveKeychainData(value: String) {
        Keychain.set(service: ViewController.serviceID, account: ViewController.accountID, value: value)
    }
    
    private func deleteKeychainData() {
        Keychain.delete(service: ViewController.serviceID, account: ViewController.accountID)
    }
    
    private func setLabels(status: String, data: String) {
        statusLabel.text = status
        dataLabel.text = data
    }
    
    private func setButtons(isEnable: Bool) {
        deletePinNumberButton.isEnabled = isEnable
        getPinNumberButton.isEnabled = isEnable
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == maxPinNumberCount, string != "" {
            return false
        } else {
            if string == "" {
                savePinNumberButton.isEnabled = range.location == maxPinNumberCount ? true : false
            } else {
                savePinNumberButton.isEnabled = (range.location + 1) == maxPinNumberCount ? true : false
            }
            return true
        }
    }
    
}

class EnableButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? UIColor.blue : UIColor.lightGray
        }
    }
    
}
