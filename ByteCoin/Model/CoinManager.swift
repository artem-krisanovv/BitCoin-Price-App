import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinPrice(_ coinManager: CoinManager, coinPrice: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies="
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(_ currency: String) {
        fetchCoinPrice(currency)
        
    }
    
    func fetchCoinPrice(_ selectedCurrency: String) {
        let urlString = "\(baseURL)\(selectedCurrency)"
        performRequest(urlString, currency: selectedCurrency)
    }
    
    func performRequest(_ urlString: String, currency: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error ?? NSError())
                    return
                }
                if let safeData = data {
                    if let price = self.parseJSON(safeData, currency: currency) {
                        self.delegate?.didUpdateCoinPrice(self, coinPrice: price)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data, currency: String) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            if let price = decodedData.bitcoin[currency.lowercased()] {
                return CoinModel(coinPrice: price)
            } else {
                return nil
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

