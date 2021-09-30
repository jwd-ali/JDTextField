//
//  AnimatedTextField.swift
//  CustomTextField
//
//  Created by Jawad Ali on 26/09/2021.
//

import UIKit
@IBDesignable
open class JDTextField: UITextField {

  //MARK:- Views
  private lazy var shapeLayer = CAShapeLayerFactory.createShapeLayer()
  private lazy var shapeLayerRight = CAShapeLayerFactory.createShapeLayer()
  private lazy var shapeLayerLeft = CAShapeLayerFactory.createShapeLayer()

  @IBInspectable dynamic open var shapeColor = UIColor.red.withAlphaComponent(0.3) { didSet { layoutIfNeeded() } }
  @IBInspectable dynamic open var placeHolderFont: UIFont = UIFont.boldSystemFont(ofSize: 20) { didSet { layoutIfNeeded() } }
  @IBInspectable dynamic open var errorLabelFont: UIFont = UIFont.boldSystemFont(ofSize: 14) { didSet { layoutIfNeeded() } }
  @IBInspectable dynamic open var errorLabelColor: UIColor = .red { didSet { layoutIfNeeded() } }
  @IBInspectable dynamic open var lineWidth: CGFloat = 4 { didSet { layoutIfNeeded() } }

  public enum ShapeType {
    case circular
    case square
  }

  private lazy var floatingLabel: UILabel = {
    let label = UILabel()
    label.text = placeholder?.uppercased()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  open override var placeholder: String? { didSet {
    floatingLabel.text = placeholder?.uppercased()
    layoutIfNeeded() }
  }

  private var leftLabelConstraint: NSLayoutConstraint!
  private var centerLabelConstraint: NSLayoutConstraint!
  private var topLabelConstraint: NSLayoutConstraint!
  private var heightErrorLabelConstraint: NSLayoutConstraint!
  private var topErrorLabelConstraint: NSLayoutConstraint!

  private let offset: CGFloat = 30
  private let topOffset: CGFloat = 6
  private let speed: Double = 0.2
  private var shapeType: ShapeType = .circular

  private lazy var allLayers = [shapeLayer, shapeLayerLeft, shapeLayerRight]

  //MARK:- init
  public init(type: ShapeType) {
    super.init(frame: .zero)
    shapeType = type
    commonInit()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  public override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 70)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    updatePaths()
    setColors()
    setFonts()
    setLineWidth()
  }
}

private extension JDTextField {

  func setColors() {
    allLayers.forEach { $0.strokeColor = shapeColor.cgColor }
    self.textColor = tintColor
    floatingLabel.textColor = isFirstResponder ? tintColor : shapeColor
    errorLabel.textColor = errorLabelColor
  }

  func setFonts() {
    floatingLabel.font = placeHolderFont
    errorLabel.font = errorLabelFont
  }

  func setLineWidth() {
    allLayers.forEach { $0.lineWidth = lineWidth }
  }

  func commonInit() {
    self.borderStyle = .none
    self.font = UIFont.systemFont(ofSize: 20)
    setupView()
    addConstraints()
    self.addTarget(self, action: #selector(becomeResponder), for: .editingDidBegin)
    self.addTarget(self, action: #selector(resignResponder), for: .editingDidEnd)
  }

  func setupView() {

    [shapeLayer, shapeLayerLeft, shapeLayerRight].forEach(layer.addSublayer)
    addSubview(floatingLabel)
    addSubview(errorLabel)
  }

  func addConstraints() {
    leftLabelConstraint = floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset)
    centerLabelConstraint = floatingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    topLabelConstraint = floatingLabel.topAnchor.constraint(equalTo: topAnchor)

    topErrorLabelConstraint = errorLabel.topAnchor.constraint(equalTo: topAnchor)
    heightErrorLabelConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)

    NSLayoutConstraint.activate ( [
      leftLabelConstraint,
      centerLabelConstraint,
      floatingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset),
      errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset),
      errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset),
      topErrorLabelConstraint,
      heightErrorLabelConstraint
    ])
  }

  func updatePaths() {
    topErrorLabelConstraint.constant = bounds.maxY
    let placeholderWidth = floatingLabel.text?.width(withConstrainedHeight: .infinity, font: floatingLabel.font)
    let halfLineWidth = lineWidth/2

    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: bounds.minX + offset + halfLineWidth, y: bounds.maxY-lineWidth/2))
    bezierPath.addLine(to: CGPoint(x: bounds.maxX - offset - halfLineWidth, y: bounds.maxY-lineWidth/2))

    shapeLayer.path = bezierPath.cgPath

    if shapeType == .circular {
    (shapeLayerLeft.path, shapeLayerRight.path) = circularShape(halfLineWidth: halfLineWidth, placeholderWidth: placeholderWidth)
    } else {
      (shapeLayerLeft.path, shapeLayerRight.path) = squareShape(halfLineWidth: halfLineWidth, placeholderWidth: placeholderWidth)
    }

    shapeLayerRight.strokeEnd = 0
    shapeLayerLeft.strokeEnd = 0

  }

  func squareShape(halfLineWidth: CGFloat, placeholderWidth: CGFloat?) -> (CGPath, CGPath) {

    let bezierPathRight = UIBezierPath()
    bezierPathRight.move(to: CGPoint(x: bounds.maxX - offset + halfLineWidth, y: bounds.maxY - halfLineWidth))
    bezierPathRight.addLine(to: CGPoint(x: bounds.maxX - halfLineWidth, y: bounds.maxY - halfLineWidth))
    bezierPathRight.addLine(to: CGPoint(x: bounds.maxX - halfLineWidth, y: topOffset + lineWidth*2))
    bezierPathRight.addLine(to: CGPoint(x: offset + (placeholderWidth ?? 0.0), y: bezierPathRight.currentPoint.y))

    let bezierPathLeft = UIBezierPath()
    bezierPathLeft.move(to: CGPoint(x: offset - halfLineWidth, y: bounds.maxY - halfLineWidth))
    bezierPathLeft.addLine(to: CGPoint(x: .leastNormalMagnitude, y: bounds.maxY - halfLineWidth))
    bezierPathLeft.addLine(to: CGPoint(x: .leastNormalMagnitude, y: topOffset + lineWidth*2))
    bezierPathLeft.addLine(to: CGPoint(x: offset - halfLineWidth, y: topOffset + lineWidth*2))

    return (bezierPathLeft.cgPath, bezierPathRight.cgPath)
  }

  func circularShape(halfLineWidth: CGFloat, placeholderWidth: CGFloat?) -> (CGPath, CGPath) {
    let bezierPathRight = UIBezierPath()
    bezierPathRight.addArc(withCenter: CGPoint(x: bounds.maxX - offset + halfLineWidth, y: bounds.midY + topOffset), radius: bounds.midY-topOffset - halfLineWidth, startAngle: 90.deg2rad , endAngle: -90.deg2rad, clockwise: false)
    bezierPathRight.addLine(to: CGPoint(x: offset + (placeholderWidth ?? 0.0), y: bezierPathRight.currentPoint.y))

    let bezierPathLeft = UIBezierPath()
        bezierPathLeft.addArc(withCenter: CGPoint(x: offset - halfLineWidth, y: bounds.midY + topOffset), radius: bounds.midY - halfLineWidth - topOffset, startAngle: 90.deg2rad, endAngle: 270.deg2rad, clockwise: true)

    return (bezierPathLeft.cgPath, bezierPathRight.cgPath)
  }
}

// MARK: - Actions on textfield responder and resign
private extension JDTextField {
  @objc func becomeResponder() {
    guard let text = text, text.isEmpty else {
      return
    }
    shapeLayerLeft.strokeAnimation(duration: speed, from: 0, to: 1)
    shapeLayerRight.strokeAnimation(duration: speed, from: 0, to: 1)

    leftLabelConstraint.constant = offset + 10
    centerLabelConstraint.isActive = false
    topLabelConstraint.isActive = true

    UIView.animate(withDuration: speed) {
      self.layoutIfNeeded()
    }

  }

  @objc func resignResponder() {
    guard let text = text, text.isEmpty else {
      return
    }
    shapeLayerLeft.strokeAnimation(duration: speed, from: 1, to: 0)
    shapeLayerRight.strokeAnimation(duration: speed, from: 1, to: 0)

    leftLabelConstraint.constant = offset
    centerLabelConstraint.isActive = true
    topLabelConstraint.isActive = false


    UIView.animate(withDuration: speed) {
      self.layoutIfNeeded()
    }


  }
}

// MARK: - TextField override rect
extension JDTextField {
  open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return .zero
  }

  open override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return adjustedTextBounds(super.editingRect(forBounds: bounds))
  }
  
  open override func textRect(forBounds bounds: CGRect) -> CGRect {
    return adjustedTextBounds(super.textRect(forBounds: bounds))
  }

  private func adjustedTextBounds(_ bounds: CGRect) -> CGRect {
    CGRect(x: bounds.origin.x + offset, y: bounds.origin.y + topOffset*2, width: bounds.size.width - offset*2, height: bounds.size.height - topOffset*2)
  }

}

public extension JDTextField {
  func showError(with message: String) {
    heightErrorLabelConstraint.constant = 30
    errorLabel.text = message
    errorLabel.shake()
  }

  func hideError() {
    heightErrorLabelConstraint.constant = 0
    errorLabel.text = nil
  }
}
