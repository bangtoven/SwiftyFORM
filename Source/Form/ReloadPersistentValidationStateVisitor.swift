// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import Foundation

class ReloadPersistentValidationStateVisitor: FormItemVisitor {
	
	class func validateAndUpdateUI(_ items: [FormItem]) {
		let visitor = ReloadPersistentValidationStateVisitor()
		for item in items {
			item.accept(visitor)
		}
	}
	
	func visitMeta(_ object: MetaFormItem) {}
	func visitCustom(_ object: CustomFormItem) {}
	func visitStaticText(_ object: StaticTextFormItem) {}
	
	func visitTextField(_ object: TextFieldFormItem) {
		object.reloadPersistentValidationState()
	}
	
	func visitTextView(_ object: TextViewFormItem) {}
	func visitViewController(_ object: ViewControllerFormItem) {}
	func visitOptionPicker(_ object: OptionPickerFormItem) {}
	func visitDatePicker(_ object: DatePickerFormItem) {}
	func visitButton(_ object: ButtonFormItem) {}
	func visitOptionRow(_ object: OptionRowFormItem) {}
	func visitSwitch(_ object: SwitchFormItem) {}
	func visitStepper(_ object: StepperFormItem) {}
	func visitSlider(_ object: SliderFormItem) {}
	func visitSection(_ object: SectionFormItem) {}
	func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem) {}
	func visitSectionHeaderView(_ object: SectionHeaderViewFormItem) {}
	func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem) {}
	func visitSectionFooterView(_ object: SectionFooterViewFormItem) {}
}
