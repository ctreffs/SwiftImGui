//
//  Helper.swift
//  
//
//  Created by Christian Treffs on 31.08.19.
//

// MARK: - helper
extension String {
    public func cStrPtr(using encoding: String.Encoding = .utf8) -> UnsafePointer<CChar>! {
        guard let cString: [CChar] = self.cString(using: encoding) else {
            assertionFailure("could not create cString with encoding \(encoding) from \(self)")
            return nil
        }

        return cString.withUnsafeBufferPointer { ptr -> UnsafePointer<CChar>? in
            guard let startAddress = ptr.baseAddress else {
                assertionFailure("could not get start address of cString \(cString)")
                return nil
            }

            return startAddress
        }
    }
}
