// MIT license. Copyright (c) 2015 SwiftyFORM. All rights reserved.
import Foundation

extension Bundle {
	public enum FormLoadViewError: ErrorProtocol {
		case expectedXibToExistButGotNil
		case expectedXibToContainJustOneButGotDifferentNumberOfObjects
		case xibReturnedWrongType
	}
	
	/* 
	usage:
	let cell: ContactPickerCell = try NSBundle.mainBundle().form_loadView("ContactPickerCell")
	*/
	public func form_loadView<T>(_ name: String) throws -> T {
		let topLevelObjects: [AnyObject]! = loadNibNamed(name, owner: self, options: nil)
		if topLevelObjects == nil {
			throw FormLoadViewError.expectedXibToExistButGotNil
		}
		if topLevelObjects.count != 1 {
			throw FormLoadViewError.expectedXibToContainJustOneButGotDifferentNumberOfObjects
		}
		let firstObject: AnyObject! = topLevelObjects.first
		guard let result = firstObject as? T else {
			throw FormLoadViewError.xibReturnedWrongType
		}
		return result
	}
}
