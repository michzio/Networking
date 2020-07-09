import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        MockRouter.mockUploadFile = nil
    }
    
    override func tearDown() {
        
        MockRouter.mockUploadFile = nil
        
        super.tearDown()
    }
    
    func testRouter_withSampleEndpoint_createsURLRequest() {
       
        // given
        let endpoint = MockRouter.sample
        
        // when
        let urlRequest = try? endpoint.asURLRequest()
        
        // then
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url?.absoluteString, "https://mockapi.com/sample")
        XCTAssertEqual(urlRequest?.httpMethod, "GET")
    }
    
    func testRouter_withUploadFileEndpoint_createsMultipartFormData() {
        
        // given
        let endpoint = MockRouter.uploadFile
        let data = "Test".data(using: .utf8)!
        let file = FileUploadInfo(data: data)
        
        // when
        MockRouter.mockUploadFile = file
        let formData = endpoint.multipartFormData()
        let mockData = whenData(from: file, with: "boundary")
        
        // then
        XCTAssertNotNil(formData)
        XCTAssertEqual(formData, mockData)
    }

    func whenData(from file: FileUploadInfo, with boundary: String = "boundary") -> Data {
        
        var data = Data()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(file.param)\"; filename=\"\(file.name)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(file.mime)\r\n\r\n".data(using: .utf8)!)
        data.append(file.data)
            
        // end multipart HTTP data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
    static var allTests = [
        ("testRouter_withSampleEndpoint_createsURLRequest", testRouter_withSampleEndpoint_createsURLRequest),
        ("testRouter_withUploadFileEndpoint_createsMultipartFormData",
            testRouter_withUploadFileEndpoint_createsMultipartFormData)
    ]
}
