// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit


public protocol FormItemVisitor {
	func visitMeta(_ object: MetaFormItem)
	func visitCustom(_ object: CustomFormItem)
	func visitStaticText(_ object: StaticTextFormItem)
	func visitTextField(_ object: TextFieldFormItem)
	func visitTextView(_ object: TextViewFormItem)
	func visitViewController(_ object: ViewControllerFormItem)
	func visitOptionPicker(_ object: OptionPickerFormItem)
	func visitOptionRow(_ object: OptionRowFormItem)
	func visitDatePicker(_ object: DatePickerFormItem)
	func visitButton(_ object: ButtonFormItem)
	func visitSwitch(_ object: SwitchFormItem)
	func visitStepper(_ object: StepperFormItem)
	func visitSlider(_ object: SliderFormItem)
	func visitSection(_ object: SectionFormItem)
	func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem)
	func visitSectionHeaderView(_ object: SectionHeaderViewFormItem)
	func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem)
	func visitSectionFooterView(_ object: SectionFooterViewFormItem)
}

public class FormItem: NSObject {
	
	public override init() {
	}
	
	func accept(_ visitor: FormItemVisitor) {}
	
	// For serialization to json purposes, eg. "firstName"
	public var elementIdentifier: String?
	public func elementIdentifier(_ elementIdentifier: String?) -> Self {
		self.elementIdentifier = elementIdentifier
		return self
	}
	
	// For styling purposes, eg. "bottomRowInFirstSection"
	public var styleIdentifier: String?
	public func styleIdentifier(_ styleIdentifier: String?) -> Self {
		self.styleIdentifier = styleIdentifier
		return self
	}

	// For styling purposes, eg. "leftAlignedGroup0"
	public var styleClass: String?
	public func styleClass(_ styleClass: String?) -> Self {
		self.styleClass = styleClass
		return self
	}
}
