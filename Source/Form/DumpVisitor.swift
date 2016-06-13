// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import Foundation

public class DumpVisitor: FormItemVisitor {
	public init() {
	}
	
	class func dump(_ prettyPrinted: Bool = true, items: [FormItem]) -> Data {
		var result = [Dictionary<String, AnyObject>]()
		var rowNumber: Int = 0
		for item in items {
			let dumpVisitor = DumpVisitor()
			item.accept(dumpVisitor)
			
			
			var dict = Dictionary<String, AnyObject>()
			dict["row"] = rowNumber
			
			let validateVisitor = ValidateVisitor()
			item.accept(validateVisitor)
			switch validateVisitor.result {
			case .valid:
				dict["validate-status"] = "ok"
			case .hardInvalid(let message):
				dict["validate-status"] = "hard-invalid"
				dict["validate-message"] = message
			case .softInvalid(let message):
				dict["validate-status"] = "soft-invalid"
				dict["validate-message"] = message
			}
			
			dict.update(dumpVisitor.dict)
			
			result.append(dict)
			rowNumber += 1
		}
		
		do {
			let options: JSONSerialization.WritingOptions = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : []
			let data = try JSONSerialization.data(withJSONObject: result, options: options)
			return data
		} catch _ {
		}
		
		return Data()
	}
	
	private var dict = Dictionary<String, AnyObject>()
	
	public func visitMeta(_ object: MetaFormItem) {
		dict["class"] = "MetaFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["value"] = object.value
	}

	public func visitCustom(_ object: CustomFormItem) {
		dict["class"] = "CustomFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
	}
	
	public func visitStaticText(_ object: StaticTextFormItem) {
		dict["class"] = "StaticTextFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["value"] = object.value
	}
	
	public func visitTextField(_ object: TextFieldFormItem) {
		dict["class"] = "TextFieldFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["value"] = object.value
		dict["placeholder"] = object.placeholder
	}
	
	public func visitTextView(_ object: TextViewFormItem) {
		dict["class"] = "TextViewFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["value"] = object.value
	}
	
	public func visitViewController(_ object: ViewControllerFormItem) {
		dict["class"] = "ViewControllerFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
	}
	
	public func visitOptionPicker(_ object: OptionPickerFormItem) {
		dict["class"] = "OptionPickerFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["placeholder"] = object.placeholder
		dict["value"] = object.selected?.title
	}
	
	func convertOptionalDateToJSON(_ date: Date?) -> AnyObject {
		if let date = date {
			return date.description
		}
		return NSNull()
	}
	
	public func visitDatePicker(_ object: DatePickerFormItem) {
		dict["class"] = "DatePickerFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["date"] = convertOptionalDateToJSON(object.value)
		dict["datePickerMode"] = object.datePickerMode.description
		dict["locale"] = object.locale ?? NSNull()
		dict["minimumDate"] = convertOptionalDateToJSON(object.minimumDate)
		dict["maximumDate"] = convertOptionalDateToJSON(object.minimumDate)
	}
	
	public func visitButton(_ object: ButtonFormItem) {
		dict["class"] = "ButtonFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
	}
	
	public func visitOptionRow(_ object: OptionRowFormItem) {
		dict["class"] = "OptionRowFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["state"] = object.selected
	}

	public func visitSwitch(_ object: SwitchFormItem) {
		dict["class"] = "SwitchFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
		dict["value"] = object.value
	}

	public func visitStepper(_ object: StepperFormItem) {
		dict["class"] = "StepperFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
	}
	
	public func visitSlider(_ object: SliderFormItem) {
		dict["class"] = "SliderFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["value"] = object.value
		dict["minimumValue"] = object.minimumValue
		dict["maximumValue"] = object.maximumValue
	}
	
	public func visitSection(_ object: SectionFormItem) {
		dict["class"] = "SectionFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
	}
	
	public func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem) {
		dict["class"] = "SectionHeaderTitleFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
	}
	
	public func visitSectionHeaderView(_ object: SectionHeaderViewFormItem) {
		dict["class"] = "SectionHeaderViewFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
	}
	
	public func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem) {
		dict["class"] = "SectionFooterTitleFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
		dict["title"] = object.title
	}

	public func visitSectionFooterView(_ object: SectionFooterViewFormItem) {
		dict["class"] = "SectionFooterViewFormItem"
		dict["elementIdentifier"] = object.elementIdentifier
		dict["styleIdentifier"] = object.styleIdentifier
		dict["styleClass"] = object.styleClass
	}
}
