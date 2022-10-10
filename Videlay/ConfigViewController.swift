//
//  ConfigViewController.swift
//  Videlay
//
//  Created by June Kim on 10/9/22.
//

import UIKit

protocol ConfigViewControllerDelegate: AnyObject {
  func configVCDidChangeConfig()
}

enum ConfigType: Int {
  case duration
  case interval
}

class ConfigViewController: UIViewController {
  
  static let durationControlRowKey = "durationControlRowKey"
  static let intervalControlRowKey = "intervalControlRowKey"

  weak var delegate: ConfigViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addChevron()
    addControlStack()
  }
  
  func addChevron() {
    let chevron = UIImageView(image: UIImage(systemName: "chevron.down")!)
    view.addSubview(chevron)
    chevron.pinTopToParent(margin: 8, insideSafeArea: true)
    chevron.centerXInParent()
  }
  
  func addControlStack() {
    let controlStack = UIStackView()
    controlStack.axis = .vertical
    controlStack.alignment = .center
    view.addSubview(controlStack)
    controlStack.centerXInParent()
    controlStack.centerYInParent()

    let durationControlRow = UIStackView()
    durationControlRow.axis = .horizontal
    durationControlRow.alignment = .fill
    controlStack.addArrangedSubview(durationControlRow)
    durationControlRow.set(width: UIScreen.main.bounds.width - 10)
    durationControlRow.set(height: 75)

    let durationLabel = UILabel()
    durationLabel.text = "Record duration (seconds)"
    durationLabel.font = .systemFont(ofSize: 16)
    durationLabel.textColor = .black
    durationControlRow.addArrangedSubview(durationLabel)

    let durationControl = UIPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    durationControl.tag = ConfigType.duration.rawValue
    durationControl.dataSource = self
    durationControl.delegate = self
    durationControlRow.addArrangedSubview(durationControl)
    durationControl.set(width: 100)
    durationControl.set(height: 65)
    durationControl.selectRow(UserDefaults.standard.integer(forKey: ConfigViewController.durationControlRowKey), inComponent: 0, animated: false)
    

    let intervalControlRow = UIStackView()
    intervalControlRow.axis = .horizontal
    intervalControlRow.alignment = .fill
    controlStack.addArrangedSubview(intervalControlRow)
    intervalControlRow.set(width: UIScreen.main.bounds.width - 10)
    intervalControlRow.set(height: 75)

    let intervalLabel = UILabel()
    intervalLabel.text = "Interval duration (minutes)"
    intervalLabel.font = .systemFont(ofSize: 16)
    intervalLabel.textColor = .black
    intervalControlRow.addArrangedSubview(intervalLabel)
    
    let intervalControl = UIPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    intervalControl.tag = ConfigType.interval.rawValue
    intervalControl.dataSource = self
    intervalControl.delegate = self
    intervalControlRow.addArrangedSubview(intervalControl)
    intervalControl.set(width: 100)
    intervalControl.set(height: 65)
    intervalControl.selectRow(UserDefaults.standard.integer(forKey: ConfigViewController.intervalControlRowKey), inComponent: 0, animated: false)
  }
  
  static func seconds(for durationRow: Int) -> Float {
    let kink: Float = 20
    if durationRow < Int(kink) - 1 {
      return 0.1 + Float(durationRow) * 0.1
    }
    return -kink + 1 + kink * 0.1 + Float(durationRow)
  }
  
  static func configuredDurationSeconds() -> Float {
    return seconds(for: UserDefaults.standard.value(forKey: ConfigViewController.durationControlRowKey) as? Int ?? 0)
  }
  
  static func configuredIntervalMinutes() -> Float {
    let defaultsValue = UserDefaults.standard.value(forKey: ConfigViewController.intervalControlRowKey) as? Int ?? 0
    return Float(defaultsValue + 1)
  }
}

extension ConfigViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch ConfigType(rawValue: pickerView.tag) {
    case .duration:
      return 30
    case .interval:
      return 20
    default:
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch ConfigType(rawValue: pickerView.tag) {
    case .duration:
      UserDefaults.standard.set(row, forKey: ConfigViewController.durationControlRowKey)
    case .interval:
      UserDefaults.standard.set(row, forKey: ConfigViewController.intervalControlRowKey)
    default:
      break
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch ConfigType(rawValue: pickerView.tag) {
    case .duration:
      return String(format: "%.1f", ConfigViewController.seconds(for: row))
    case .interval:
      return String(row + 1)
    default:
      return ""
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var title = ""
    switch ConfigType(rawValue: pickerView.tag) {
    case .duration:
      title = String(format: "%.1f", ConfigViewController.seconds(for: row))
    case .interval:
      title = String(row + 1)
    default:
      title = ""
    }
    return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
  }
  
}
