import Foundation

public struct SATime {
    public static var format = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZ"
    //static var format = "YYYY-MM-dd'T'HH:mm:ss"
}

public enum SATimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    public func dateComponents(interval: Int) -> NSDateComponents {
        let components:NSDateComponents = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
		case .Hours:
			components.minute = interval * 60
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        //default:
        //	components.day = interval
        }
        return components
    }
}

public struct SATimeInterval {
    var interval: Int
    var unit: SATimeIntervalUnit
    
    public var ago: NSDate {
        let calendar = NSCalendar.currentCalendar()
            let today = NSDate()
            let components = unit.dateComponents(-self.interval)
            return calendar.dateByAddingComponents(components, toDate: today, options: [])!
    }
    
    init(interval: Int, unit: SATimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

var a = SATimeInterval(interval: 10, unit: SATimeIntervalUnit.Months)

public extension Int {
    public var seconds: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Seconds)
    }
    public var minutes: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Minutes)
    }
    public var hours: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Hours)
    }
    public var days: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Days)
    }
    public var months: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Months);
    }
    public var years: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.Years)
    }
}

public func - (left:NSDate, right:SATimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

public func + (left:NSDate, right:SATimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: [])!
}

var test1 = 2.years.ago
var test2 = NSDate() - 4.days
var test3 = NSDate() + 5.months

public func < (left:NSDate, right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedAscending) {
        isEarlier = true
    }
    return isEarlier
}

public func > (left:NSDate, right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isLater = false
    if (result == NSComparisonResult.OrderedDescending) {
        isLater = true
    }
    return isLater
}

public func == (left:NSDate, right: NSDate) -> Bool {
    let result:NSComparisonResult = left.compare(right)
    var isEqual = false
    if (result == NSComparisonResult.OrderedSame) {
        isEqual = true
    }
    return isEqual
}

var test4 = test2 < test3
var test5 = test3 > test1
var test6 = NSDate() == test1

public extension NSDate {
    public class func yesterday() -> NSDate {
        return NSDate() - 1.days
    }
    
    public func to_string(format:String) -> String? {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
       
        return formatter.stringFromDate(self)
    }
    public func to_string() -> String? {
		return to_string("YYYY-MM-dd HH:mm:ss.SSS")
	}
}

var test7 = NSDate.yesterday().to_string("MM/dd")

public extension String {
   
	//	the original one - we're not going to use it
    public func to_date(format:String = "dd/MM/yyyy") -> NSDate? {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        
        return formatter.dateFromString(self)
    }

	//	with timezone - it's makes more sense in API calls
	public var date: NSDate? {
		get {
			let format = SATime.format
			let formatter = NSDateFormatter()
			formatter.dateFormat = format
			return formatter.dateFromString(self)
		}
	}
}

var test8 = "12/01/2014".to_date("MM/dd/yyyy")
var test9 = "12/01/2014".to_date()