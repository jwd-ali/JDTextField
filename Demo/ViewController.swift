//
//  ViewController.swift
//  Demo
//
//  Created by Jawad Ali on 29/09/2021.
//

import UIKit
import JDTextField
class ViewController: UIViewController {

  private lazy var circularTextField: JDTextField = {
    let field = JDTextField(type: .circular)
    field.placeholder = "Circular Text Field"
    field.shapeColor = UIColor.red.withAlphaComponent(0.3)
    field.lineWidth = 2
    field.tintColor = .red
    return field
  }()

  private lazy var squareTextField: JDTextField = {
    let field = JDTextField(type: .square)
    field.placeholder = "Square"
    field.layer.shadowColor = UIColor.red.cgColor
    field.shapeColor = .black
    field.tintColor = .black
    return field
  }()

  private lazy var emailTextField: JDTextField = {
    let field = JDTextField(type: .circular)
    field.placeholder = "Email"
    field.shapeColor = UIColor.gray.withAlphaComponent(0.3)
    field.lineWidth = 2
    field.autocapitalizationType = .none
    field.tintColor = .gray
    field.delegate = self
    field.spellCheckingType = .no
    return field
  }()

  private lazy var stack: UIStackView = {
    let stack = UIStackView()
    stack.alignment = .fill
    stack.axis = .vertical
    stack.spacing = 50
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
   setupView()
    setupConstraints()
  }

}

private extension ViewController {
  func setupView() {
    [circularTextField, squareTextField, emailTextField].forEach(stack.addArrangedSubview)
    view.addSubview(stack)
  }

  func setupConstraints() {
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      stack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
      stack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
    ])
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if !textField.isEmail() { emailTextField.showError(with: "Please enter valid email") } else { emailTextField.hideError() }
    textField.resignFirstResponder()
    return true
  }
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    false
  }
}
