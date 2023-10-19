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

## Tuist 구조
  <img width="858" alt="스크린샷 2023-10-19 오후 8 17 42" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/292e0dfe-0b4a-4061-8ce4-7f23fbd59f0f">


  
## TroubleShooting
1. Network Layer
1-1. Endpoint 로 API 관리  

<img width="881" alt="스크린샷 2023-10-19 오후 9 10 04" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/054cb2da-d3db-4cd1-89c7-087dd49be538">

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
2-1. 다양한 이벤트 상황 핸들링  
<img width="906" alt="스크린샷 2023-10-19 오후 8 53 33" src="https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/23b71baf-cfe4-4b49-a3e4-12281b242f5b">

   검색 후 API 를 호출해야하는 다양한 상황에 대응하기 위해서, 각각의 이벤트들을 Combine 으로 관리해서 모은 후, 한번에 API 를 구독하는 형태로 코드를 작성하였습니다.  
   - ViewController 내부에 있는 이벤트인 Text 입력, Cell 터치 감지 등은 라이브러리 CombineCocoa 를 활용해서 이벤트를 수신하였습니다.  
  
   - ViewController 외부에 있는 이벤트인 Cell 내부의 다운로드 버튼 클릭 이벤트는 NotificationCenter 를 활용해서 이벤트를 수신하였습니다.
   
   - 이벤트들을 주관하는 ViewController 에서 `bind()` 라는 함수를 생성한 후, 모든 Input 값에 해당하는 이벤트들을 Output 의 실제 액션으로 전환해주었습니다.  

```swift
func bind() {
        self.resultController.viewDidLoad()
        
        let pagingPublisher = Publishers.Merge(
            NotificationCenter.default.publisher(for: .searchAppPagingTriggered),
            NotificationCenter.default.publisher(for: .enterSearch)
        )
            .map { [weak self] _ in
                self?.searchController.searchBar.text = self?.resultViewModel.currentTerm ?? ""
                return self?.resultViewModel.currentTerm ?? ""
            }
            .eraseToAnyPublisher()
        
        let tableCellSelectedPublisher = tableView.didSelectRowPublisher
            .map { [weak self] index in
                let term = self?.resultViewModel.histories[index.item - 1 == -1 ? 0 : index.item - 1] ?? ""
                NotificationCenter.default.post(name: .startSearch, object: self)
                DispatchQueue.main.async {
                    self?.tableView.deselectRow(at: index, animated: true)
                    self?.searchController.searchBar.text = term
                    self?.searchController.isActive = true
                    self?.searchController.showsSearchResultsController = true
                }
                return term
            }
            .eraseToAnyPublisher()
        
        let searchResultPublisher = Publishers.Merge3(searchClickedValuePublisher, pagingPublisher, tableCellSelectedPublisher)
            .eraseToAnyPublisher()        
        
        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: searchController.searchBar.textDidChangePublisher,
            searchResultPublisher: searchResultPublisher,
            searchCancelPublisher: searchController.searchBar.cancelButtonClickedPublisher,
            userButtonTapPublisher: profileIcon.tapPublisher
        )
        
        var output = resultViewModel.transform(input: input)
        
        output.historyPublisher.sink { item in
            self.resultController.reloadHistorySnapshot(history: item)
        }.store(in: &cancellabels)
        
        output.fetchAppPublisher.sink { status in
            switch status {
            case .finished: break
            case .failure(let error): print(error)
            }
        } receiveValue: { [weak self] value in
            self?.resultViewModel.searchResults += value.results ?? []
            self?.resultController.reloadResultSnapshot(searchResult: self?.resultViewModel.searchResults.compactMap { DataSourceItem.searchResult($0) } ?? [])
        }.store(in: &cancellabels)
        
        output.cancelPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.resultViewModel.searchResults = []
            }.store(in: &cancellabels)
        
        output.userPublisher.sink { _ in
        }.store(in: &cancellabels)
    }
```

3. TestCase  
테스트케이스를 작성하여 특정 시나리오가 작동하는지 확인하였습니다.


```swift
// Test 파일의 기본적인 입력 코드입니다.
// Combine 이 활용되었습니다.

final class FeatureSearchTests: XCTestCase {
    
    private var cancellabels = Set<AnyCancellable>()
    let textChangePublisher = PassthroughSubject<String, Never>()
    let searchResultPublisher = PassthroughSubject<String, Never>()
    let searchCancelPublisher = PassthroughSubject<Void, Never>()
    let userButtonTapPublisher = PassthroughSubject<Void, Never>()
    ...   
```

3-1. 입력 후 엔터를 하면 페이징 결과에 따라 10개의 결과물만 받아야 하는 상황  


https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/3003c4ec-f91b-4aa1-ba74-6dc45189bd98




```swift
func test_ViewModel_fetchApp() {
        let resultViewModel = FeatureSearchResultViewModel(searchResults: iTuensDataResponseModel(from: nil))

        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: textChangePublisher.eraseToAnyPublisher(),
            searchResultPublisher: searchResultPublisher.eraseToAnyPublisher(),
            searchCancelPublisher: searchCancelPublisher.eraseToAnyPublisher(),
            userButtonTapPublisher: userButtonTapPublisher.eraseToAnyPublisher()
        )
        
        // given
        let expectation = XCTestExpectation(description: "Fetch App from ViewModel Expectation")
        let output = resultViewModel.transform(input: input)
        var testValue: iTuensDataResponseModel? = nil
        output.fetchAppPublisher.sink { status in
            switch status {
            case .finished: break
            case .failure(let error): print(error)
            }
        } receiveValue: { value in
            expectation.fulfill()
            testValue = value
        }.store(in: &cancellabels)
        
        // when
        searchResultPublisher.send("Apple")

        // then
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(testValue?.results?.count, 10)
    }
```  

3-2. 입력 후 최근 검색어에서 입력어를 제대로 찾는지 확인하는 상황

https://github.com/Newon-universe/AppStore-mock-coding/assets/80164141/89da9dad-4b7e-4db4-a8a6-0f11cc6bb564


```swift
 func test_ViewModel_historyCheck() {
        let resultViewModel = FeatureSearchResultViewModel(searchResults: iTuensDataResponseModel(from: nil))

        let input = FeatureSearchResultViewModel.Input(
            searchHistoryPublisher: textChangePublisher.eraseToAnyPublisher(),
            searchResultPublisher: searchResultPublisher.eraseToAnyPublisher(),
            searchCancelPublisher: searchCancelPublisher.eraseToAnyPublisher(),
            userButtonTapPublisher: userButtonTapPublisher.eraseToAnyPublisher()
        )
        
        var output = resultViewModel.transform(input: input)
        
        // given
        let expectation = XCTestExpectation(description: "history check from ViewModel Expectation")
        var testValue: [History]? = nil
        output.historyPublisher.sink { items in
            let histories = items.compactMap { item -> History? in
                if case .searchHistory(let model) = item {
                    return model
                }
                return nil
            }
            
            expectation.fulfill()
            testValue = histories
        }.store(in: &cancellabels)
        
        // when
        searchResultPublisher.send("Apple")
        textChangePublisher.send("pp")
        
        // then
        wait(for: [expectation], timeout: 5.0)
        let checkValue = testValue?.filter { $0.title == "Apple" }.map { $0.title }
        XCTAssertEqual(checkValue?.count, 1)
        XCTAssertEqual(checkValue?.first, "Apple")
    }
```

