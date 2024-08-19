TRAITS = Argonaut::JSON.parse(File.read('/data/traits.json'), symbolize_keys: true, extensions: true)
GODS = Argonaut::JSON.parse(File.read('/data/gods.json'), symbolize_keys: true, extensions: true)
BASE_DECK = Argonaut::JSON.parse(File.read('/data/basic_deck.json'), symbolize_keys: true, extensions: true)
CARD_LIST = Argonaut::JSON.parse(File.read('/data/cards.json'), symbolize_keys: true, extensions: true)
NAMES = Argonaut::JSON.parse(File.read('/data/names.json'), symbolize_keys: true, extensions: true)

VOLUME_SPRITE = { x: 1200,
                  y: 600,
                  w: 64,
                  h: 64,
                  path: "/sprites/volume/1.png",
                  angle: 0,
                  a: 255,
                  volume: 0.1,
                  type: :sound }

