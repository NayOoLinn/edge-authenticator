extension String {
    func inserting(separator: String, every n: Int) -> String {
        guard n > 0 else { return self }
        
        return stride(from: 0, to: count, by: n).map { index in
            let start = self.index(startIndex, offsetBy: index)
            let end = self.index(start, offsetBy: n, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
        .joined(separator: separator)
    }
}
