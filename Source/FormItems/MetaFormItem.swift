// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import Foundation

/// This is an invisible field, that is submitted along with the json
public class MetaFormItem: FormItem {
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitMeta(self)
	}
	
	public var value: AnyObject?

	@discardableResult
	public func value(_ value: AnyObject?) -> Self {
		self.value = value
		return self
	}
}
