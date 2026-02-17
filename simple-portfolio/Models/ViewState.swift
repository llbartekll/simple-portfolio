import Foundation

enum ViewState<T> {
    case loading
    case loaded(T)
    case error(String)
    case empty
}
