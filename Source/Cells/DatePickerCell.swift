// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit

public struct DatePickerCellModel {
	var title: String = ""
	var toolbarMode: ToolbarMode = .simple
	var datePickerMode: UIDatePickerMode = .dateAndTime
	var locale: Locale? = nil // default is [NSLocale currentLocale]. setting nil returns to default
	var minimumDate: Date? = nil // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
	var maximumDate: Date? = nil // default is nil
	
	var valueDidChange: (Date) -> Void = { (date: Date) in
		SwiftyFormLog("date \(date)")
	}
}

public class DatePickerCell: UITableViewCell, SelectRowDelegate {
	public let model: DatePickerCellModel

	public init(model: DatePickerCellModel) {
		/*
		Known problem: UIDatePickerModeCountDownTimer is buggy and therefore not supported
		
		UIDatePicker has a bug in it when used in UIDatePickerModeCountDownTimer mode. The picker does not fire the target-action
		associated with the UIControlEventValueChanged event the first time the user changes the value by scrolling the wheels.
		It works fine for subsequent changes.
		http://stackoverflow.com/questions/20181980/uidatepicker-bug-uicontroleventvaluechanged-after-hitting-minimum-internal
		http://stackoverflow.com/questions/19251803/objective-c-uidatepicker-uicontroleventvaluechanged-only-fired-on-second-select
		
		Possible work around: Continuously poll for changes.
		*/
		assert(model.datePickerMode != .countDownTimer, "CountDownTimer is not supported")

		self.model = model
		super.init(style: .value1, reuseIdentifier: nil)
		selectionStyle = .default
		textLabel?.text = model.title
		
		updateValue()
		
		assignDefaultColors()
	}

	public required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	public func assignDefaultColors() {
		textLabel?.textColor = UIColor.black()
		detailTextLabel?.textColor = UIColor.gray()
	}
	
	public func assignTintColors() {
		let color = self.tintColor
		SwiftyFormLog("assigning tint color: \(color)")
		textLabel?.textColor = color
		detailTextLabel?.textColor = color
	}
	
	public func resolveLocale() -> Locale {
		return model.locale ?? Locale.current()
	}
	
	public lazy var datePicker: UIDatePicker = {
		let instance = UIDatePicker()
		instance.datePickerMode = self.model.datePickerMode
		instance.minimumDate = self.model.minimumDate
		instance.maximumDate = self.model.maximumDate
		instance.addTarget(self, action: #selector(DatePickerCell.valueChanged), for: .valueChanged)
		instance.locale = self.resolveLocale()
		return instance
		}()
	

	public lazy var toolbar: SimpleToolbar = {
		let instance = SimpleToolbar()
		weak var weakSelf = self
		instance.jumpToPrevious = {
			if let cell = weakSelf {
				cell.gotoPrevious()
			}
		}
		instance.jumpToNext = {
			if let cell = weakSelf {
				cell.gotoNext()
			}
		}
		instance.dismissKeyboard = {
			if let cell = weakSelf {
				cell.dismissKeyboard()
			}
		}
		return instance
		}()
	
	public func updateToolbarButtons() {
		if model.toolbarMode == .simple {
			toolbar.updateButtonConfiguration(self)
		}
	}
	
	public func gotoPrevious() {
		SwiftyFormLog("make previous cell first responder")
		form_makePreviousCellFirstResponder()
	}
	
	public func gotoNext() {
		SwiftyFormLog("make next cell first responder")
		form_makeNextCellFirstResponder()
	}
	
	public func dismissKeyboard() {
		SwiftyFormLog("dismiss keyboard")
		_ = resignFirstResponder()
	}
	
	public override var inputView: UIView? {
		return datePicker
	}
	
	public override var inputAccessoryView: UIView? {
		if model.toolbarMode == .simple {
			return toolbar
		}
		return nil
	}

	public func valueChanged() {
		let date = datePicker.date
		model.valueDidChange(date)

		updateValue()
	}
	
	public func obtainDateStyle(_ datePickerMode: UIDatePickerMode) -> DateFormatter.Style {
		switch datePickerMode {
		case .time:
			return .noStyle
		case .date:
			return .longStyle
		case .dateAndTime:
			return .shortStyle
		case .countDownTimer:
			return .noStyle
		}
	}
	
	public func obtainTimeStyle(_ datePickerMode: UIDatePickerMode) -> DateFormatter.Style {
		switch datePickerMode {
		case .time:
			return .shortStyle
		case .date:
			return .noStyle
		case .dateAndTime:
			return .shortStyle
		case .countDownTimer:
			return .shortStyle
		}
	}
	
	public func humanReadableValue() -> String {
		if model.datePickerMode == .countDownTimer {
			let t = datePicker.countDownDuration
			let date = Date(timeIntervalSinceReferenceDate: t)
			let calendar = Calendar(identifier: Calendar.Identifier.gregorian)!
			calendar.timeZone = TimeZone(forSecondsFromGMT: 0)
			let components = calendar.components([Calendar.Unit.hour, Calendar.Unit.minute], from: date)
			let hour = components.hour
			let minute = components.minute
			return String(format: "%02d:%02d", hour!, minute!)
		}
		if true {
			let date = datePicker.date
			//SwiftyFormLog("date: \(date)")
			let dateFormatter = DateFormatter()
			dateFormatter.locale = self.resolveLocale()
			dateFormatter.dateStyle = obtainDateStyle(model.datePickerMode)
			dateFormatter.timeStyle = obtainTimeStyle(model.datePickerMode)
			return dateFormatter.string(from: date)
		}
	}

	public func updateValue() {
		detailTextLabel?.text = humanReadableValue()
	}
	
	public func setDateWithoutSync(_ date: Date?, animated: Bool) {
		SwiftyFormLog("set date \(date), animated \(animated)")
		datePicker.setDate(date ?? Date(), animated: animated)
		updateValue()
	}

	public func form_didSelectRow(_ indexPath: IndexPath, tableView: UITableView) {
		// Hide the datepicker wheel, if it's already visible
		// Otherwise show the datepicker
		
		let alreadyFirstResponder = (self.form_firstResponder() != nil)
		if alreadyFirstResponder {
			tableView.form_firstResponder()?.resignFirstResponder()
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		//SwiftyFormLog("will invoke")
		// hide keyboard when the user taps this kind of row
		tableView.form_firstResponder()?.resignFirstResponder()
		_ = self.becomeFirstResponder()
		tableView.deselectRow(at: indexPath, animated: true)
		//SwiftyFormLog("did invoke")
	}
	
	// MARK: UIResponder
	
	public override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	public override func becomeFirstResponder() -> Bool {
		let result = super.becomeFirstResponder()
		updateToolbarButtons()
		assignTintColors()
		return result
	}
	
	public override func resignFirstResponder() -> Bool {
		super.resignFirstResponder()
		assignDefaultColors()
		return true
	}
}
