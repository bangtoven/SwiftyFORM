// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import Foundation

public class TextViewFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitTextView(self)
	}
	
	public var placeholder: String = ""
	public func placeholder(_ placeholder: String) -> Self {
		self.placeholder = placeholder
		return self
	}
	
	public var title: String = ""
	public func title(_ title: String) -> Self {
		self.title = title
		return self
	}
	
	typealias SyncBlock = (value: String) -> Void
	var syncCellWithValue: SyncBlock = { (string: String) in
		SwiftyFormLog("sync is not overridden")
	}
	
	internal var innerValue: String = ""
	public var value: String {
		get {
			return self.innerValue
		}
		set {
			self.assignValueAndSync(newValue)
		}
	}
	
	func assignValueAndSync(_ value: String) {
		innerValue = value
		syncCellWithValue(value: value)
	}
}
