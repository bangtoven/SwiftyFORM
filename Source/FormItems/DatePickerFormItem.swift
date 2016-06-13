// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import Foundation

public enum DatePickerFormItemMode {
	case time
	case date
	case dateAndTime
	
	var description: String {
		switch self {
		case .time: return "Time"
		case .date: return "Date"
		case .dateAndTime: return "DateAndTime"
		}
	}
}

public class DatePickerFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitDatePicker(self)
	}
	
	public var title: String = ""
	public func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	typealias SyncBlock = (date: Date?, animated: Bool) -> Void
	var syncCellWithValue: SyncBlock = { (date: Date?, animated: Bool) in
		SwiftyFormLog("sync is not overridden")
	}
	
	internal var innerValue: Date? = nil
	public var value: Date? {
		get {
			return self.innerValue
		}
		set {
			self.setValue(newValue, animated: false)
		}
	}
	
	public func setValue(_ date: Date?, animated: Bool) {
		innerValue = date
		syncCellWithValue(date: date, animated: animated)
	}
	
	public var datePickerMode: DatePickerFormItemMode = .dateAndTime
	public var locale: Locale? // default is [NSLocale currentLocale]. setting nil returns to default
	public var minimumDate: Date? // specify min/max date range. default is nil. When min > max, the values are ignored. Ignored in countdown timer mode
	public var maximumDate: Date? // default is nil
}
