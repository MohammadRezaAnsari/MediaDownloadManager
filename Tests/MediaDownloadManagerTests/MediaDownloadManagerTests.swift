import XCTest
@testable import MediaDownloadManager


import PDFKit


final class MediaDownloadManagerTests: XCTestCase {
    
    var sut: MediaDownloadManager! = MediaDownloadManager()
    
    func testExample() throws {
        
//        let url = URL(string: "https://www.clickdimensions.com/links/TestPDFfile.pdf")!
//
//        let url = URL(string: "http://download.microsoft.com/download/F/E/6/FE6F3347-35A8-4780-90FC-A57C668E2A4A/CRM2011_ISV_WhitePaper_Nov2010.pdf")!
//
//
//
//        sut.download(with: url) {
//            print($0)
//        } onResult: { data in
//
//            //                let image = UIImage(data: data)
//
//            if #available(iOS 11.0, *) {
//
//                let pdf = PDFDocument(data: data)
//                pdf?.documentAttributes?[PDFDocumentAttribute.titleAttribute] = "TestPDFfile"
//                print(pdf?.documentAttributes![PDFDocumentAttribute.titleAttribute])
//                print(pdf)
//            } else {
//                // Fallback on earlier versions
//            }
//        } onError: {
//            print($0)
//        }
//
//
//
//        let exp = expectation(description: "Test after 5 seconds")
//        let result = XCTWaiter.wait(for: [exp], timeout: 10.0)
//        if result == XCTWaiter.Result.timedOut {
//        } else {
//            XCTFail("Delay interrupted")
//        }
    }
}
