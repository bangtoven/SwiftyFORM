// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import Foundation

public class CustomFormItem: FormItem {
	public enum CustomFormItemError: ErrorProtocol {
		case couldNotCreate
	}

	public typealias CreateCell = (Void) throws -> UITableViewCell
	public var createCell: CreateCell = { throw CustomFormItemError.couldNotCreate }
	
	override func accept(_ visitor: FormItemVisitor) {
		visitor.visitCustom(self)
	}
}
