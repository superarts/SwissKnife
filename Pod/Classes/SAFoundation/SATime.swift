import Foundation

public struct SATime {
    public static var format = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZ"
    //static var format = "YYYY-MM-dd'T'HH:mm:ss"
}

public enum SATimeIntervalUnit {
    case seconds, minutes, hours, days, months, years
    
    public func dateComponents(_ interval: Int) -> DateComponents {
        var components:DateComponents = DateComponents()
        
        switch (self) {
        case .seconds:
            components.second = interval
        case .minutes:
            components.minute = interval
		case .hours:
			components.minute = interval * 60
        case .days:
            components.day = interval
        case .months:
            components.month = interval
        case .years:
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
    
    public var ago: Date {
        let calendar = Calendar.current
            let today = Date()
            let components = unit.dateComponents(-self.interval)
            return (calendar as NSCalendar).date(byAdding: components, to: today, options: [])!
    }
    
    init(interval: Int, unit: SATimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

var a = SATimeInterval(interval: 10, unit: SATimeIntervalUnit.months)

public extension Int {
    public var seconds: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.seconds)
    }
    public var minutes: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.minutes)
    }
    public var hours: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.hours)
    }
    public var days: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.days)
    }
    public var months: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.months);
    }
    public var years: SATimeInterval {
        return SATimeInterval(interval: self, unit: SATimeIntervalUnit.years)
    }
}

public func - (left:Date, right:SATimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(-right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

public func + (left:Date, right:SATimeInterval) -> Date {
    let calendar = Calendar.current
    let components = right.unit.dateComponents(right.interval)
    return (calendar as NSCalendar).date(byAdding: components, to: left, options: [])!
}

var test1 = 2.years.ago
var test2 = Date() - 4.days
var test3 = Date() + 5.months

/*
public extension Date {
	public static func < (left:Date, right: Date) -> Bool {
		let result:ComparisonResult = left.compare(right)
		var isEarlier = false
		if (result == ComparisonResult.orderedAscending) {
			isEarlier = true
		}
		return isEarlier
	}

	public static func > (left:Date, right: Date) -> Bool {
		let result:ComparisonResult = left.compare(right)
		var isLater = false
		if (result == ComparisonResult.orderedDescending) {
			isLater = true
		}
		return isLater
	}

	public static func == (left:Date, right: Date) -> Bool {
		let result:ComparisonResult = left.compare(right)
		var isEqual = false
		if (result == ComparisonResult.orderedSame) {
			isEqual = true
		}
		return isEqual
	}
}

var test4 = test2 < test3
var test5 = test3 > test1
var test6 = Date() == test1
*/

public extension Date {
    public static func yesterday() -> Date {
        return Date() - 1.days
    }
    
    public func to_string(_ format:String) -> String? {
        let formatter:DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = format
       
        return formatter.string(from: self)
    }
    public func to_string() -> String? {
		return to_string("YYYY-MM-dd HH:mm:ss.SSS")
	}
}

var test7 = Date.yesterday().to_string("MM/dd")

public extension String {
   
	//	the original one - we're not going to use it
    public func to_date(_ format:String = "dd/MM/yyyy") -> Date? {
        let formatter:DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone.local
        formatter.dateFormat = format
        
        return formatter.date(from: self)
    }

	//	with timezone - it's makes more sense in API calls
	public var date: Date? {
		get {
			let format = SATime.format
			let formatter = DateFormatter()
			formatter.dateFormat = format
			return formatter.date(from: self)
		}
	}
}

var test8 = "12/01/2014".to_date("MM/dd/yyyy")
var test9 = "12/01/2014".to_date()