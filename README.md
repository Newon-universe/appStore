# AppStore-mock-coding

## 개요
AppStore 중에서 검색화면을 Mock coding 한 프로젝트입니다.  

![Swift](https://img.shields.io/badge/Swift-F05138?style=flat-square&logo=Swift&logoColor=white)
![Badge](https://img.shields.io/badge/UIKit-F05138?style-flat-square&logo-Swift&logoColor=white)
![CombineCocoa](https://github.com/CombineCommunity/CombineCocoa/workflows/CombineCocoa/badge.svg?branch=main)
[![Tuist badge](https://img.shields.io/badge/Powered%20by-Tuist-blue)](https://tuist.io)
![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=flat-square&logo=Xcode&logoColor=white)

<br/>

기능
- 검색 전 최근 검색어 목록
- 검색 기능 + 검색 중 관련 검색어 목록
- 검색 결과 목록
- 검색 결과 디테일 화면

<img src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/6dd989a0-984f-49f6-a2b8-663b6003cac5" width="200" height="400"/>
<img src= "https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/bc0292f3-4a92-4e3a-857a-874836170773" width="200" height="400"/>

## Install ⬇️
Tuist 설치
```shell
curl -Ls https://install.tuist.io | bash
```

프로젝트 오픈
```shell
git clone https://github.com/Newon-universe/AppStore-mock-coding.git
cd 클론한 폴더
tuist fetch
tuist generate
```

## Tuist 구조 ⬇️
  <img width="858" alt="스크린샷 2023-10-19 오후 8 17 42" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/292e0dfe-0b4a-4061-8ce4-7f23fbd59f0f">


  
## TroubleShooting
1. Network Layer  
1-1. Endpoint 로 API 관리  
   이후 API 의 확장성과 하드코딩으로 인한 오류를 대비해서 Network Layer 를 구축하고 여러 API 들을 관리하려고 하였습니다.  
   - Tuist 로 Network 기능 전체가 모듈화된 상태여서, 제네릭타입을 통해 리턴받고자 하는 타입을 NetworkService 에서 호출하는 쪽에서 정할 수 있도록 하였습니다.  

   - Endpoint 를 Enum 으로 관리하여서, 이후 같은 API 를 사용하고자 할 때 NetworkService 의 값으로 편하게 넣을 수 있도록 하였습니다. 

   - 같은 API 를 completion, Combine, Async-await 형태 3개로 작성하여 필요한 API 를 사용할 수 있도록 하였습니다.
  
   ```swift
   public enum Endpoint {
    
    case fetchApp(term: String, country: String = "KR", offset: Int = 0,limit: Int = 10)
    
    var request: URLRequest? {
        guard let url = self.url else { assertionFailure("URL is not valid"); return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod
        request.httpBody = self.httpBody
        request.addValues(for: self)
        request.cachePolicy = .returnCacheDataElseLoad
        
        return request
    }
    
    private var url: URL? {        
        var components = URLComponents()
        components.scheme = Constants.SCHEME
        components.host = Constants.BASE_URL
        components.path = Constants.PATH_SEARCH
        components.queryItems = self.queryItems
        
        return components.url
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .fetchApp(let term, let country, let offset, let limit):
            return [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "country", value: country),
                URLQueryItem(name: "entity", value: "software"),
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        }
    }
    
    private var httpMethod: String {
        switch self {
        case .fetchApp: return HTTP.Method.get.rawValue
        }
    }
    
    private var httpBody: Data? {
        switch self {
        case .fetchApp: return nil
        }
    }
   }
   ```  
   
     ```swift
     public enum NetworkServiceError: Error {
      case networkError
      case noInternet
      case unknownError
      case decodingError
      case serverError(String)
      case unauthorized
     }

     public class NetworkService<T: Decodable> {
      public static func fetchAppWithCombine(with endpoint: Endpoint) -> AnyPublisher<T, NetworkServiceError> {
          //길이 상 completion 과 Async-Await 함수는 생략하였습니다. NetworkService 에서 확인하실 수 있습니다.
          guard let request = endpoint.request?.url else { return Fail(error: NetworkServiceError.noInternet).eraseToAnyPublisher() }
          
          return URLSession.shared.dataTaskPublisher(for: request)
              .tryMap { data, response in
                  guard let httpResponse = response as? HTTPURLResponse, 200 ... 299 ~= httpResponse.statusCode else {
                      throw NetworkServiceError.networkError
                  }
                  guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 401 else {
                      throw NetworkServiceError.unauthorized
                  }
                  
                  return data
              }
              .decode(type: T.self, decoder: JSONDecoder())
              .mapError { error in
                  if let urlError = error as? URLError {
                      switch urlError.code {
                      case .notConnectedToInternet:
                          return NetworkServiceError.noInternet
                      default:
                          return NetworkServiceError.unknownError
                      }
                  } else if error is DecodingError {
                      return NetworkServiceError.decodingError
                  } else {
                    return NetworkServiceError.serverError(error.localizedDescription)
                  }
              }
              .eraseToAnyPublisher()
      }
     
     ```  

     1-2. Cache 를 활용한 Network 데이터 호출 최적화  
     - CollectionView 가 다양하게 있는 앱의 특성상 이미 한번 호출한 API 나 이미지여도, 캐싱을 하지 않으면 네트워크 데이터를 너무 많이 호출하는 형태가 되었습니다.
     - 이를 해결하기 위해서 NetworkService 를 호출한 곳에서 캐싱을 관리하여, API 호출을 최적화하였습니다.  
  

     ```swift
     import UIKit
      // 이미지 캐싱을 담을 NSCache 를 생성하는 클래스입니다.
      internal final class ImageCache {
        internal lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
            let cache = NSCache<AnyObject, AnyObject>()
            cache.totalCostLimit = config.memoryLimit
            return cache
        }()
      
        private let config: Config
      
        public struct Config {
            let countLimit: Int
            let memoryLimit: Int
          
            static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100)
        }
    
        init(config: Config = Config.defaultConfig) {
            self.config = config
        }
      }

     // 실제 사용 방식입니다.
     // CollectionView 에서 동일한 ImageView 여도 검색 결과에 따라 다른 Image 를 호출하는 것을 확인하여 캐싱을 ImageView 단위로 진행하고,
     // load 를 통해 캐시 확인 -> 이미지 호출 방식으로 진행하였습니다.
     extension UIImageView {
      private static let cache = ImageCache()
      
      public func load(from url: String, completion: @escaping (Bool) -> Void) {
          DispatchQueue.main.async { self.image = nil }
          guard let url = URL(string: url) else { return }
          
          if let image = UIImageView.cache[url] {
              DispatchQueue.main.async { self.image = image }
              return
          }
          
          let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
          URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
              if let data = data, let image = UIImage(data: data) {
                  UIImageView.cache.insertImage(image, for: url)
                  completion(true)
                  DispatchQueue.main.async {
                      self?.image = image
                  }
              } else {
                  completion(false)
              }
          }.resume()
        }
      }
     ```

     API 호출의 경우 API 호출을 담당하는 ViewModel 에서 NSCache 를 갖고서 캐시를 담당하는 형태로 작성하였습니다.  
  
     ```swift
     public final class FeatureSearchResultViewModel: ObservableObject {
    
     private var urlCache: NSCache<AnyObject, AnyObject> = {
       let cache = NSCache<AnyObject, AnyObject>()
       cache.totalCostLimit = 100
       return cache
     }()

     func transform(input: Input) -> Output {
     // ... 생략 
       let searchResultsPublisher = input.searchResultPublisher
         .flatMap { [unowned self] term in
             currentTerm = term
             return Future<iTuensDataResponseModel, NetworkServiceError> { promise in
               Task {
                 if let data = self.urlCache.object(forKey: term as AnyObject) as? iTuensDataResponseModel {
                   promise(.success(data))
                 } else {
                   let data = await self.fetchAppAsync(for: term)
                   switch data {
                   case .success(let response):
                     self.histories = [term]
                     promise(.success(response))
                   case .failure(let error):
                     promise(.failure(error))
                   }
                 }
               }
             }
         }
         .eraseToAnyPublisher()
         // ... 생략
     }
     ```


2. Combine
<img width="906" alt="스크린샷 2023-10-19 오후 8 53 33" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/23b71baf-cfe4-4b49-a3e4-12281b242f5b">
<img width="912" alt="스크린샷 2023-10-19 오후 8 53 54" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/e6fc3b61-1890-4f61-9576-ac83f0dfe563">




3. TestCase
