//
//  ViewController.swift
//  openWeather
//
//  Created by 노민경 on 2021/12/07.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextField!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text{
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func configureView(weatherInformation: WeatherInformation){
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.minTempLabel.text = "최저 : \(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.maxTempLabel.text = "최고 : \(Int(weatherInformation.temp.maxTemp - 273.15))°C"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(cityName: String){
        guard let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=87305b8145f410aac38956b447677b1c") else { return }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url){ [weak self] data, response, error in
            let successRange = (200..<300) //200~300번대의 메시지는 성공적인 데이터
        
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                // 200 번대라면 유효한 데이터 범위이므로 데이터를 표시해줌
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                // 네트워크 작업은 별도의 스레드에서 진행되고 응답이 온다고 해도 자동으로 메인 스레드로 돌아오지 않기 때문에
                // 메인스테리드에서 작업을 할 수 있도록 해야 함
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation) // 현재 날씨 정보가 표시되도록
                }
            } else{ // 200번대 데이터가 아니라면 에러사항
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message) // 서버에서 응답받는 에러 메시지가 alert에 표시되도록 함
                }
            }
        }.resume()
    }
}

