import Foundation

class StepRedirectWatcher: NSObject, URLSessionTaskDelegate {
    private var finalURL: String?
    private var completion: ((String?) -> Void)?

    func check(url: String, timeout: TimeInterval, completion: @escaping (String?) -> Void) {
        self.completion = completion
        guard let requestURL = URL(string: url) else {
            completion(nil)
            return
        }

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)

        let task = session.dataTask(with: requestURL) { [weak self] _, response, error in
            DispatchQueue.main.async {
                guard let cb = self?.completion else { return }
                self?.completion = nil
                if error != nil {
                    cb(nil)
                } else if let httpResponse = response as? HTTPURLResponse,
                          let url = httpResponse.url?.absoluteString {
                    cb(url)
                } else {
                    cb(self?.finalURL)
                }
            }
        }
        task.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let cb = self?.completion else { return }
            self?.completion = nil
            cb(nil)
            task.cancel()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString {
            finalURL = url
            if url.contains("freeprivacypolicy.com") {
                DispatchQueue.main.async {
                    guard let cb = self.completion else { return }
                    self.completion = nil
                    cb(nil)
                }
                completionHandler(nil)
                return
            }
        }
        completionHandler(request)
    }
}
