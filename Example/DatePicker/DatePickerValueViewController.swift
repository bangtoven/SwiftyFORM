// MIT license. Copyright (c) 2014 SwiftyFORM. All rights reserved.
import UIKit
import SwiftyFORM

class DatePickerValueViewController: FormViewController {
	
	lazy var datePicker_time_noValue: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("Time")
		instance.datePickerMode = .time
		return instance
		}()
	
	lazy var datePicker_date_noValue: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("Date")
		instance.datePickerMode = .date
		return instance
		}()
	
	lazy var datePicker_dateAndTime_noValue: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("DateAndTime")
		instance.datePickerMode = .dateAndTime
		return instance
		}()
	
	lazy var datePicker_time_value: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("Time")
		instance.datePickerMode = .time
		instance.value = Date(timeIntervalSinceNow: 18305) // 18305 == 5 * 60 * 60 + 5 * 60 + 5
		return instance
		}()
	
	lazy var datePicker_date_value: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("Date")
		instance.datePickerMode = .date
		instance.value = Date(timeIntervalSinceNow: 4406400) // 4406400 == 51 * 24 * 60 * 60
		return instance
		}()
	
	lazy var datePicker_dateAndTime_value: DatePickerFormItem = {
		let instance = DatePickerFormItem()
		instance.title("DateAndTime")
		instance.datePickerMode = .dateAndTime
		instance.value = Date(timeIntervalSinceNow: 4406400) // 4406400 == 51 * 24 * 60 * 60
		return instance
		}()
	
	override func populate(_ builder: FormBuilder) {
		builder.navigationTitle = "DatePicker & Value"
		builder.toolbarMode = .simple
		builder.demo_showInfo("Demonstration of\nUIDatePicker with initial value")
		builder += SectionHeaderTitleFormItem().title("Without initial date")
		builder += datePicker_time_noValue
		builder += datePicker_date_noValue
		builder += datePicker_dateAndTime_noValue
		builder += SectionHeaderTitleFormItem().title("With initial date")
		builder += datePicker_time_value
		builder += datePicker_date_value
		builder += datePicker_dateAndTime_value
	}
	
}
