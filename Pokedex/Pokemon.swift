import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
	let sprites: Sprite
	let species: PokemonSpecient
}

struct Sprite: Codable {
	let front_default: String
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct PokemonSpecient: Codable {
	let url: String
}

struct FlavorTextEntries: Codable {
	let flavor_text_entries: [FlavorText]
}

struct FlavorText: Codable {
	let language: DesLanguage
	let flavor_text: String
}

struct DesLanguage: Codable {
	let name: String
}
