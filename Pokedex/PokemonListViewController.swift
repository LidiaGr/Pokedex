import UIKit

class PokemonListViewController: UITableViewController, UISearchBarDelegate {
	@IBOutlet var searchBar: UISearchBar!
	
	var pokemon: [PokemonListResult] = []
	
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		searchBar.delegate = self
		self.definesPresentationContext = true

		
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
	
	var searchRes: [PokemonListResult] = []
	var isSearch: Bool = false
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count == 0 {
			isSearch = false
			self.tableView.reloadData()
		} else {
			searchRes = pokemon.filter({ (text) -> Bool in
				let tmp: NSString = text.name as NSString
				let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
				return range.location != NSNotFound
			})
			if searchRes.count == 0 {
				isSearch = false
			} else {
				isSearch = true
			}
			self.tableView.reloadData()
		}
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isSearch {
			return self.searchRes.count
		}
		return self.pokemon.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
		if isSearch {
			cell.textLabel?.text = capitalize(text: searchRes[indexPath.row].name)
		} else {
			cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
		}
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
                let destination = segue.destination as? PokemonViewController,
                let index = tableView.indexPathForSelectedRow?.row {
			if isSearch {
				destination.url = searchRes[index].url
			}
			else {
				destination.url = pokemon[index].url				
			}
        }
    }
}
