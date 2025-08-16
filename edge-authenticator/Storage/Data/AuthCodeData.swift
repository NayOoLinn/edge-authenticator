//
import RealmSwift

class AuthCodeData: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var key: String = ""
    var code: String = ""
    
    override class func ignoredProperties() -> [String] {
        return ["code"]
    }
}
