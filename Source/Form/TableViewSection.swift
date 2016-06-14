// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit

public enum TableViewSectionPart {
	case none
	case titleString(string: String)
	case titleView(view: UIView)
	
	typealias CreateBlock = (Void) -> TableViewSectionPart
	
	func title() -> String? {
		switch self {
		case let .titleString(string):
			return string
		default:
			return nil
		}
	}

	func view() -> UIView? {
		switch self {
		case let .titleView(view):
			return view
		default:
			return nil
		}
	}
	
	func height() -> CGFloat {
		switch self {
		case let .titleView(view):
			let view2: UIView = view
			return view2.frame.size.height
		default:
			return UITableViewAutomaticDimension
		}
	}
}

public class TableViewSection : NSObject, UITableViewDataSource, UITableViewDelegate {
	private let cells: [UITableViewCell]
	private let headerBlock: TableViewSectionPart.CreateBlock
	private let footerBlock: TableViewSectionPart.CreateBlock
	
	init(cells: [UITableViewCell], headerBlock: TableViewSectionPart.CreateBlock, footerBlock: TableViewSectionPart.CreateBlock) {
		self.cells = cells
		self.headerBlock = headerBlock
		self.footerBlock = footerBlock
		super.init()
	}

	private lazy var header: TableViewSectionPart = {
		return self.headerBlock()
		}()

	private lazy var footer: TableViewSectionPart = {
		return self.footerBlock()
		}()

	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cells.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cells[(indexPath as NSIndexPath).row]
	}
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return header.title()
	}
	
	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return footer.title()
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return header.view()
	}

	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return footer.view()
	}

	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return header.height()
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return footer.height()
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = cells[(indexPath as NSIndexPath).row] as? SelectRowDelegate {
			cell.form_didSelectRow(indexPath, tableView: tableView)
		}
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let cell = cells[(indexPath as NSIndexPath).row] as? CellHeightProvider {
			return cell.form_cellHeight(indexPath, tableView: tableView)
		}
		return UITableViewAutomaticDimension
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cells[(indexPath as NSIndexPath).row] as? WillDisplayCellDelegate {
			cell.form_willDisplay(tableView, forRowAtIndexPath: indexPath)
		}
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		if let cell = cells[(indexPath as NSIndexPath).row] as? AccessoryButtonDelegate {
			cell.form_accessoryButtonTapped(indexPath, tableView: tableView)
		}
	}
}


/// UITableView with multiple sections
public class TableViewSectionArray : NSObject, UITableViewDataSource, UITableViewDelegate {
	public typealias SectionType = protocol<NSObjectProtocol, UITableViewDataSource, UITableViewDelegate>
	
	private var sections: [SectionType]
	
	public init(sections: [SectionType]) {
		self.sections = sections
		super.init()
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].tableView(tableView, numberOfRowsInSection: section)
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return sections[(indexPath as NSIndexPath).section].tableView(tableView, cellForRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		sections[(indexPath as NSIndexPath).section].tableView?(tableView, didSelectRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].tableView?(tableView, titleForHeaderInSection: section)
	}

	public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return sections[section].tableView?(tableView, titleForFooterInSection: section)
	}
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return sections[section].tableView?(tableView, viewForHeaderInSection: section)
	}
	
	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return sections[section].tableView?(tableView, viewForFooterInSection: section)
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sections[section].tableView?(tableView, heightForHeaderInSection: section) ?? UITableViewAutomaticDimension
	}
	
	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return sections[section].tableView?(tableView, heightForFooterInSection: section) ?? UITableViewAutomaticDimension
	}
	
	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return sections[(indexPath as NSIndexPath).section].tableView?(tableView, heightForRowAt: indexPath) ?? 0
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		sections[(indexPath as NSIndexPath).section].tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		sections[(indexPath as NSIndexPath).section].tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
	}

	// MARK: UIScrollViewDelegate
	
	/// hide keyboard when the user starts scrolling
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		scrollView.form_firstResponder()?.resignFirstResponder()
	}
	
	/// hide keyboard when the user taps the status bar
	public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
		scrollView.form_firstResponder()?.resignFirstResponder()
		return true
	}
}

