import UIKit

var savedData = UserDefaults.standard

class PokemonViewController: UIViewController {
    var url: String!
	var isCaught = [String: Bool]()
	
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
	@IBOutlet var catchButton: UIButton!
	@IBOutlet var photo: UIImageView!
	@IBOutlet var specDescription: UITextView!
	
	@IBAction func toggleCatch() {
		if isCaught[nameLabel.text!] == true {
			isCaught[nameLabel.text!] = false
//			catchButton.backgroundColor = .red
			catchButton.setTitle("Catch", for: .normal)
		} else {
			isCaught[nameLabel.text!] = true
//			catchButton.backgroundColor = .green
			catchButton.setTitle("Release", for: .normal)
		}
		savedData.set(isCaught[nameLabel.text!], forKey: nameLabel.text!)
	}
	
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
		specDescription.text = ""
		
		catchButton.layer.cornerRadius = 50
		catchButton.layer.borderWidth = 1
		
		loadPokemon()
    }

	func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
					
					let spriteUrl = URL(string: result.sprites.front_default)
					let spriteData = try? Data(contentsOf: spriteUrl!)
					self.photo.image = UIImage(data: spriteData!)
					
					self.loadDescription(url: result.species.url)
					
					if savedData.bool(forKey: self.nameLabel.text!) == true {
						self.isCaught[self.nameLabel.text!] = true
//						self.catchButton.backgroundColor = .green
						self.catchButton.setTitle("Release", for: .normal)
					} else {
						self.isCaught[self.nameLabel.text!] = false
//						self.catchButton.backgroundColor = .red
					}
					
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }

	func loadDescription(url: String) {
		URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
			guard let data = data else {
				return
			}

			do {
				let result = try JSONDecoder().decode(FlavorTextEntries.self, from: data)
				DispatchQueue.main.async {
					for index in result.flavor_text_entries {
						if index.language.name == "en" {
							self.specDescription.text = index.flavor_text
						}
					}
				}
			}
			catch let error {
				print(error)
			}
		}.resume()
	}
}
