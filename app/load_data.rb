TRAITS = Argonaut::JSON.parse(File.read('/data/traits.json'), symbolize_keys: true, extensions: true)
GODS = Argonaut::JSON.parse(File.read('/data/gods.json'), symbolize_keys: true, extensions: true)
BASE_DECK = Argonaut::JSON.parse(File.read('/data/basic_deck.json'), symbolize_keys: true, extensions: true)
