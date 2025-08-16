struct BaseResponse<T: Codable>: Codable {
    var status: Int?
    var message: String?
    var response: T?
}
