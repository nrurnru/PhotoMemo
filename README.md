# PhotoMemo

<img src="https://user-images.githubusercontent.com/53948757/111024719-998fec00-8423-11eb-89b0-961af0843dd3.jpg" width="300">

사진과 함께 메모를 작성하고, 서버와 동기화시켜 다른 기기에서도 그대로 이용할 수 있는 서비스입니다.

## 개요

- 1인 개발로 프로젝트를 진행하였습니다.
- RxSwift를 활용하여 MVVM-C 패턴으로 구현하였습니다.
- 뷰 구성은 Storyboard와 Autolayout을 활용하였습니다.
- 메모 저장에 필요한 서버를 Django로 간단하게 구성한 뒤 Restful API로 서버와 통신하였고, 이미지 서버는 imgur.com의 API를 이용하였습니다.
- 이외에 Alamofire, Kingfisher 등의 오픈소스 프레임워크를 활용하였습니다.

<br>

## 주요 기능

### 회원가입 / 로그인

<img src="https://user-images.githubusercontent.com/53948757/111023620-66e2f500-841d-11eb-86bc-4145b9ebb064.gif" width="250">

- 서버와 통신하여 회원가입을 하고, 로그인하여 jwt 토큰을 발급받아 RST API 통신에 사용합니다.

<br>

### 메모 작성, 수정

<img src="https://user-images.githubusercontent.com/53948757/111023626-6e0a0300-841d-11eb-9925-8dac5c5f08b6.gif" width="250"> <img src="https://user-images.githubusercontent.com/53948757/111023632-72362080-841d-11eb-83cd-fce2b64792f3.gif" width="250">

- 사진을 포함한 메모를 작성하거나 수정할 수 있습니다. 특히 텍스트를 작성할 때 키보드가 다른 View를 가리지 않도록 UX를 고려하며 구현했습니다.  

<br>
  
### 메모 검색, 삭제

<img src="https://user-images.githubusercontent.com/53948757/111023652-9b56b100-841d-11eb-9da8-c3ceed0d55ac.gif" width="250"> <img src="https://user-images.githubusercontent.com/53948757/111023630-7104f380-841d-11eb-8057-94a73f91cd2e.gif" width="250">

- 로컬의 Realm DB에 접근하여 메모 내용을 검색하거나 삭제할 수 있습니다.

<br>

### 동기화

- [Youtube 보기](https://www.youtube.com/watch?v=lX9TYKN20Uk)
- 데이터가 수정된 시간과 마지막으로 동기화된 시간을 비교해 필요한 부분만 동기화함으로써 네트워킹과 DB 접근을 최소화하여 성능을 높였습니다.

## Photomemo 서버
[Github Repository](https://github.com/nrurnru/PhotoMemoAPIServer)
