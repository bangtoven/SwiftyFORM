// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit

protocol WillPopCommandProtocol {
	func execute(_ context: ViewControllerFormItemPopContext)
}


class WillPopCustomViewController: WillPopCommandProtocol {
	let object: AnyObject
	init(object: AnyObject) {
		self.object = object
	}
	
	func execute(_ context: ViewControllerFormItemPopContext) {
		if let vc = object as? ViewControllerFormItem {
			vc.willPopViewController?(context)
			return
		}
	}
}

class WillPopOptionViewController: WillPopCommandProtocol {
	let object: ViewControllerFormItem
	init(object: ViewControllerFormItem) {
		self.object = object
	}
	
	func execute(_ context: ViewControllerFormItemPopContext) {
		object.willPopViewController?(context)
	}
}


struct PopulateTableViewModel {
	var viewController: UIViewController
	var toolbarMode: ToolbarMode
}



class PopulateTableView: FormItemVisitor {
	let model: PopulateTableViewModel
	
	var cells = [UITableViewCell]()
	var sections = [TableViewSection]()
	var headerBlock: TableViewSectionPart.CreateBlock?
	
	init(model: PopulateTableViewModel) {
		self.model = model
	}
	
	func closeSection(_ footerBlock: TableViewSectionPart.CreateBlock) {
		var headerBlock: (Void) -> TableViewSectionPart = {
			return TableViewSectionPart.none
		}
		if let block = self.headerBlock {
			headerBlock = block
		}
		
		let section = TableViewSection(cells: cells, headerBlock: headerBlock, footerBlock: footerBlock)
		sections.append(section)

		cells = [UITableViewCell]()
		self.headerBlock = nil
	}
	
	
	func visitMeta(_ object: MetaFormItem) {
		// this item is not visual
	}

	func visitCustom(_ object: CustomFormItem) {
		do {
			let cell = try object.createCell()
			cells.append(cell)
		} catch {
			print("ERROR: Could not create cell for custom form item: \(error)")

			var model = StaticTextCellModel()
			model.title = "CustomFormItem"
			model.value = "Exception"
			let cell = StaticTextCell(model: model)
			cells.append(cell)
		}
	}
	
	func visitStaticText(_ object: StaticTextFormItem) {
		var model = StaticTextCellModel()
		model.title = object.title
		model.value = object.value
		let cell = StaticTextCell(model: model)
		cells.append(cell)

		weak var weakCell = cell
		object.syncCellWithValue = { (value: String) in
			SwiftyFormLog("sync value \(value)")
			if let c = weakCell {
				var m = StaticTextCellModel()
				m.title = c.model.title
				m.value = value
				c.model = m
				c.loadWithModel(m)
			}
		}
	}
	
	func visitTextField(_ object: TextFieldFormItem) {
		var model = TextFieldFormItemCellModel()
		model.toolbarMode = self.model.toolbarMode
		model.title = object.title
		model.placeholder = object.placeholder
		model.keyboardType = object.keyboardType
		model.returnKeyType = object.returnKeyType
		model.autocorrectionType = object.autocorrectionType
		model.autocapitalizationType = object.autocapitalizationType
		model.spellCheckingType = object.spellCheckingType
		model.secureTextEntry = object.secureTextEntry
		model.model = object
		weak var weakObject = object
		model.valueDidChange = { (value: String) in
			SwiftyFormLog("value \(value)")
			weakObject?.textDidChange(value)
			return
		}
		let cell = TextFieldFormItemCell(model: model)
		cell.setValueWithoutSync(object.value)
		cells.append(cell)
		
		weak var weakCell = cell
		object.syncCellWithValue = { (value: String) in
			SwiftyFormLog("sync value \(value)")
			weakCell?.setValueWithoutSync(value)
			return
		}
		
		object.reloadPersistentValidationState = {
			weakCell?.reloadPersistentValidationState()
			return
		}
		
		object.obtainTitleWidth = {
			if let cell = weakCell {
				let size = cell.titleLabel.intrinsicContentSize()
				return size.width
			}
			return 0
		}

		object.assignTitleWidth = { (width: CGFloat) in
			if let cell = weakCell {
				cell.titleWidthMode = TextFieldFormItemCell.TitleWidthMode.assign(width: width)
				cell.setNeedsUpdateConstraints()
			}
		}
	}
	
	func visitTextView(_ object: TextViewFormItem) {
		var model = TextViewCellModel()
		model.toolbarMode = self.model.toolbarMode
		model.title = object.title
		model.placeholder = object.placeholder
		weak var weakObject = object
		model.valueDidChange = { (value: String) in
			SwiftyFormLog("value \(value)")
			weakObject?.innerValue = value
			return
		}
		let cell = TextViewCell(model: model)
		cell.setValueWithoutSync(object.value)
		cells.append(cell)

		weak var weakCell = cell
		object.syncCellWithValue = { (value: String) in
			SwiftyFormLog("sync value \(value)")
			weakCell?.setValueWithoutSync(value)
			return
		}
	}

	func visitViewController(_ object: ViewControllerFormItem) {
		let model = ViewControllerFormItemCellModel(title: object.title, placeholder: object.placeholder)
		let willPopViewController = WillPopCustomViewController(object: object)
		
		weak var weakViewController = self.model.viewController
		let cell = ViewControllerFormItemCell(model: model) { (cell: ViewControllerFormItemCell, modelObject: ViewControllerFormItemCellModel) in
			SwiftyFormLog("push")
			if let vc = weakViewController {
				let dismissCommand = PopulateTableView.prepareDismissCommand(willPopViewController, parentViewController: vc, cell: cell)
				if let childViewController = object.createViewController?(dismissCommand) {
					vc.navigationController?.pushViewController(childViewController, animated: true)
				}
			}
		}
		cells.append(cell)
	}
	
	class func prepareDismissCommand(_ willPopCommand: WillPopCommandProtocol, parentViewController: UIViewController, cell: ViewControllerFormItemCell) -> CommandProtocol {
		weak var weakViewController = parentViewController
		let command = CommandBlock { (childViewController: UIViewController, returnObject: AnyObject?) in
			SwiftyFormLog("pop: \(returnObject)")
			if let vc = weakViewController {
				let context = ViewControllerFormItemPopContext(parentViewController: vc, childViewController: childViewController, cell: cell, returnedObject: returnObject)
				willPopCommand.execute(context)
				_ = vc.navigationController?.popViewController(animated: true)
			}
		}
		return command
	}

	func visitOptionPicker(_ object: OptionPickerFormItem) {
		var model = OptionViewControllerCellModel()
		model.title = object.title
		model.placeholder = object.placeholder
		model.optionField = object
		model.selectedOptionRow = object.selected

		weak var weakObject = object
		model.valueDidChange = { (value: OptionRowModel?) in
			SwiftyFormLog("propagate from cell to model. value \(value)")
			weakObject?.innerSelected = value
			weakObject?.valueDidChange(selected: value)
		}
		
		let cell = OptionViewControllerCell(
			parentViewController: self.model.viewController,
			model: model
		)
		cells.append(cell)
		
		weak var weakCell = cell
		object.syncCellWithValue = { (selected: OptionRowModel?) in
			SwiftyFormLog("propagate from model to cell. option: \(selected?.title)")
			weakCell?.setSelectedOptionRowWithoutPropagation(selected)
		}
	}
	
	func mapDatePickerMode(_ mode: DatePickerFormItemMode) -> UIDatePickerMode {
		switch mode {
		case .date: return UIDatePickerMode.date
		case .time: return UIDatePickerMode.time
		case .dateAndTime: return UIDatePickerMode.dateAndTime
		}
	}
	
	func visitDatePicker(_ object: DatePickerFormItem) {
		var model = DatePickerCellModel()
		model.title = object.title
		model.toolbarMode = self.model.toolbarMode
		model.datePickerMode = mapDatePickerMode(object.datePickerMode)
		model.locale = object.locale
		model.minimumDate = object.minimumDate
		model.maximumDate = object.maximumDate
		
		weak var weakObject = object
		model.valueDidChange = { (date: Date) in
			SwiftyFormLog("value did change \(date)")
			weakObject?.innerValue = date
			return
		}
		
		let cell = DatePickerCell(model: model)
		
		SwiftyFormLog("will assign date \(object.value)")
		cell.setDateWithoutSync(object.value, animated: false)
		SwiftyFormLog("did assign date \(object.value)")
		cells.append(cell)
		
		weak var weakCell = cell
		object.syncCellWithValue = { (date: Date?, animated: Bool) in
			SwiftyFormLog("sync date \(date)")
			weakCell?.setDateWithoutSync(date, animated: animated)
			return
		}
	}
	
	func visitButton(_ object: ButtonFormItem) {
		var model = ButtonCellModel()
		model.title = object.title
		model.action = object.action
		let cell = ButtonCell(model: model)
		cells.append(cell)
	}

	func visitOptionRow(_ object: OptionRowFormItem) {
		weak var weakViewController = self.model.viewController
		let cell = OptionCell(model: object) {
			SwiftyFormLog("did select option")
			if let vc = weakViewController {
				if let x = vc as? SelectOptionDelegate {
					x.form_willSelectOption(object)
				}
			}
		}
		cells.append(cell)
	}
	
	func visitSwitch(_ object: SwitchFormItem) {
		var model = SwitchCellModel()
		model.title = object.title
		
		weak var weakObject = object
		model.valueDidChange = { (value: Bool) in
			SwiftyFormLog("value did change \(value)")
			weakObject?.switchDidChange(value)
			return
		}

		let cell = SwitchCell(model: model)
		cells.append(cell)

		SwiftyFormLog("will assign value \(object.value)")
		cell.setValueWithoutSync(object.value, animated: false)
		SwiftyFormLog("did assign value \(object.value)")

		weak var weakCell = cell
		object.syncCellWithValue = { (value: Bool, animated: Bool) in
			SwiftyFormLog("sync value \(value)")
			weakCell?.setValueWithoutSync(value, animated: animated)
			return
		}
	}
	
	func visitStepper(_ object: StepperFormItem) {
		var model = StepperCellModel()
		model.title = object.title
		model.value = object.value

		weak var weakObject = object
		model.valueDidChange = { (value: Int) in
			SwiftyFormLog("value \(value)")
			weakObject?.innerValue = value
			return
		}

		let cell = StepperCell(model: model)
		cells.append(cell)

		SwiftyFormLog("will assign value \(object.value)")
		cell.setValueWithoutSync(object.value, animated: true)
		SwiftyFormLog("did assign value \(object.value)")

		weak var weakCell = cell
		object.syncCellWithValue = { (value: Int, animated: Bool) in
			SwiftyFormLog("sync value \(value)")
			weakCell?.setValueWithoutSync(value, animated: animated)
			return
		}
	}

	func visitSlider(_ object: SliderFormItem) {
		var model = SliderCellModel()
		model.minimumValue = object.minimumValue
		model.maximumValue = object.maximumValue
		model.value = object.value

		
		weak var weakObject = object
		model.valueDidChange = { (value: Float) in
			SwiftyFormLog("value did change \(value)")
			weakObject?.sliderDidChange(value)
			return
		}

		let cell = SliderCell(model: model)
		cells.append(cell)

		weak var weakCell = cell
		object.syncCellWithValue = { (value: Float, animated: Bool) in
			SwiftyFormLog("sync value \(value)")
			weakCell?.setValueWithoutSync(value, animated: animated)
			return
		}
	}
	
	func visitSection(_ object: SectionFormItem) {
		let footerBlock: TableViewSectionPart.CreateBlock = {
			return TableViewSectionPart.none
		}
		closeSection(footerBlock)
	}

	func visitSectionHeaderTitle(_ object: SectionHeaderTitleFormItem) {
		if cells.count > 0 || self.headerBlock != nil {
			let footerBlock: TableViewSectionPart.CreateBlock = {
				return TableViewSectionPart.none
			}
			closeSection(footerBlock)
		}

		self.headerBlock = {
			var item = TableViewSectionPart.none
			if let title = object.title {
				item = TableViewSectionPart.titleString(string: title)
			}
			return item
		}
	}
	
	func visitSectionHeaderView(_ object: SectionHeaderViewFormItem) {
		if cells.count > 0 || self.headerBlock != nil {
			let footerBlock: TableViewSectionPart.CreateBlock = {
				return TableViewSectionPart.none
			}
			closeSection(footerBlock)
		}

		self.headerBlock = {
			let view: UIView? = object.viewBlock?()
			var item = TableViewSectionPart.none
			if let view = view {
				item = TableViewSectionPart.titleView(view: view)
			}
			return item
		}
	}

	func visitSectionFooterTitle(_ object: SectionFooterTitleFormItem) {
		let footerBlock: TableViewSectionPart.CreateBlock = {
			var footer = TableViewSectionPart.none
			if let title = object.title {
				footer = TableViewSectionPart.titleString(string: title)
			}
			return footer
		}
		closeSection(footerBlock)
	}
	
	func visitSectionFooterView(_ object: SectionFooterViewFormItem) {
		let footerBlock: TableViewSectionPart.CreateBlock = {
			let view: UIView? = object.viewBlock?()
			var item = TableViewSectionPart.none
			if let view = view {
				item = TableViewSectionPart.titleView(view: view)
			}
			return item
		}
		closeSection(footerBlock)
	}
}


