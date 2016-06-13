import Foundation

public class RegularExpressionSpecification: CompositeSpecification {
	public let regularExpression: RegularExpression
	
	public init(regularExpression: RegularExpression) {
		self.regularExpression = regularExpression
		super.init()
	}
	
	public convenience init(pattern: String) {
		let regularExpression = try! RegularExpression(pattern: pattern, options: [])
		self.init(regularExpression: regularExpression)
	}
	
	public override func isSatisfiedBy(_ candidate: Any?) -> Bool {
		guard let s = candidate as? String else { return false }
		return regularExpression.numberOfMatches(in: s, options: [], range: NSMakeRange(0, s.characters.count)) > 0
	}
}
