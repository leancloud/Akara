# Akara
A Swift networking library based on cURL.

[Akara](https://github.com/leancloud/Akara/) is a high-level networking library based on cURL. It encapsulates the trivial details of cURL. Akara aims to provide a group of concise APIs to perform request.

The code below perform a GET request:

```swift
let requset = Akara.Request(url: URL(string: "https://example.com"))
let result  = Akara.perform(request)

switch result {
case .success(let response):
    print(response.body)
case .failure(let error):
    print(error.message)
}
```

The code below perform a POST request:

```swift
let requset = Akara.Request(url: URL(string: "https://example.com"))
let result  = Akara.perform(request)

request.method = "POST"
request.addParameters(["foo": "bar"], encoding: .json)

switch result {
case .success(let response):
    print(response.body)
case .failure(let error):
    print(error.message)
}
```
