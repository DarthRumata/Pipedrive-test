//
//  APIClient.swift
//
//  Created by Rumata on 12/27/17.
//

import Foundation
import Alamofire
import RxSwift

public enum NetworkError: LocalizedError {

    case unknown
    case invalidResponse
    case mockedJSONUnreachable

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "Server is unreachable"

        case .invalidResponse:
            return "Server sent invalid data"

        case .mockedJSONUnreachable:
            return "Invalid path or content of mocked resource"
        }

    }

}

public class NetworkService {

    private let sessionManager: SessionManager
    private let baseURL: URL
    private let errorProcessor: ErrorProcessor

    static let shared = NetworkService(baseURL: URL(string: "https://testtask-c37354.pipedrive.com/v1/")!, configuration: URLSessionConfiguration.default)

    private init(baseURL: URL, configuration: URLSessionConfiguration, trustPolicies: [String: ServerTrustPolicy] = [:], errorProcessor: ErrorProcessor = DefaultErrorProcessor()) {
        self.baseURL = baseURL
        self.errorProcessor = errorProcessor

        sessionManager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: trustPolicies))
    }

    public func executeRequest<T, Request: SimpleRequest>(_ request: Request) -> Single<T> where Request.Parser.Representation == T {
        return sendRequest(
            path: request.path,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encoding,
            parser: request.parser
        )
    }

    public func executeMockRequest<T, Request: SimpleRequest>(_ request: Request) -> Single<T> where Request.Parser.Representation == T {
        return Single<T>.create { single in
            guard
                let data = FileManager.default.contents(atPath: request.path) else
            {
                single(.error(NetworkError.mockedJSONUnreachable))
                return Disposables.create()
            }
            do {
                let result = try request.parser.parse(data)

                single(.success(result))
            } catch (let error) {
                single(.error(error))
            }
            return Disposables.create()
        }
    }

    public func executeUploadRequest<T, Request: UploadRequest>(_ request: Request) -> Single<T> where Request.Parser.Representation == T {
        return uploadFile(path: request.path, data: request.data, parser: request.parser)
    }

    public func executeMultiPartRequest<T, Request: MultipartRequest>(_ request: Request) -> Single<T> where Request.Parser.Representation == T {
        return uploadMultipartData(
            path: request.path,
            headers: request.headers,
            multipartBuilder: request.multiPartFormBuilder,
            parser: request.parser
        )
    }

    private func uploadFile<T, Parser: ResponseParser>(path: String, method: HTTPMethod = .post, data: Data, parser: Parser) -> Single<T> where Parser.Representation == T {
        return Single<T>.create { [weak self] single in
            guard let self = self else {
                single(.error(NetworkError.unknown))
                return Disposables.create()
            }

            let request = self.sessionManager.upload(
                data,
                to: self.baseURL.appendingPathComponent(path),
                method: method
                ).response(queue: .global(), completionHandler: { (response) in
                    guard
                        let data = response.data else
                    {
                        single(.error(response.error ?? NetworkError.invalidResponse))
                        return
                    }
                    do {
                        let result = try parser.parse(data)

                        single(.success(result))
                    } catch (let error) {
                        single(.error(error))
                    }
                })

            return Disposables.create { request.cancel() }
        }
    }

    private func uploadMultipartData<T, Parser: ResponseParser>(path: String, method: HTTPMethod = .post, headers: HTTPHeaders, multipartBuilder: @escaping (MultipartFormData) -> Void, parser: Parser) -> Single<T> where Parser.Representation == T {
        return Single<T>.create { [weak self] single in
            guard let self = self else {
                single(.error(NetworkError.unknown))
                return Disposables.create()
            }

            self.sessionManager.upload(
                multipartFormData: multipartBuilder,
                to: self.baseURL.appendingPathComponent(path),
                method: method,
                headers: headers,
                encodingCompletion: { (encodingResult) in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload
                            .validate(statusCode: 200...205)
                            .response(queue: .global(), completionHandler: { (response) in
                                guard
                                    let data = response.data else
                                {
                                    single(.error(response.error ?? NetworkError.invalidResponse))
                                    return
                                }
                                do {
                                    let result = try parser.parse(data)

                                    single(.success(result))
                                } catch (let error) {
                                    print(String(data: data, encoding: .utf8) ?? "")
                                    single(.error(error))
                                }
                            })
                    case .failure(let error):
                        single(.error(error))
                    }
            })


            return Disposables.create { }
        }
    }

    private func sendRequest<T, Parser: ResponseParser>(path: String, method: HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = JSONEncoding.default, parser: Parser) -> Single<T> where Parser.Representation == T {
        return Single<T>.create { [weak self] single in
            guard let strongSelf = self else {
                single(.error(NetworkError.unknown))
                return Disposables.create()
            }
            let request = strongSelf.sessionManager
                .request(
                    strongSelf.baseURL.appendingPathComponent(path),
                    method: method,
                    parameters: parameters,
                    encoding: encoding
                )
                .validate(statusCode: 200...205)
                .response(queue: .global()) { [weak self] (response) in
                    guard let self = self else { return }

                    if let error = response.error {
                        let error = self.errorProcessor.process(error: error, with: response.response ?? HTTPURLResponse(), data: response.data)
                        single(.error(error))
                        return
                    }
                    guard let data = response.data else {
                        single(.error(NetworkError.invalidResponse))
                        return
                    }
                    do {
                        let result = try parser.parse(data)

                        single(.success(result))
                    } catch (let error) {
                        print(String(data: data, encoding: .utf8) ?? "")
                        print(error.localizedDescription)
                        single(.error(error))
                    }
            }

            return Disposables.create { request.cancel() }
        }
    }

}
