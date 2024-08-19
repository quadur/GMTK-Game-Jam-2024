def scene_end_of_day_tick args
  args.outputs.labels << {x: 640, y: 700, text: "DAY OVER", r: 255, alignment_enum: 1, size_enum: 10}
  args.outputs.labels << [10, 710, "framerate: #{args.gtk.current_framerate.round}"]


  4.times do |i|
    god = args.state.gods[i]
    args.outputs.labels << [640, 500+30*i+40, "#{god.name}: Power: #{god.power}(#{god.power_diff}) Happines: #{god.happiness} (#{god.happ_diff})", size_enum: -3, alignment_enum: 1]
  end

  args.outputs.sprites << [args.state.deck_cards_rect, args.state.new_cards_rect]

  args.outputs.labels << args.state.deck_cards_rect.map { |c|  c.center.merge( text: c.text,
                                                                          r: 255,
                                                                          g: 255,
                                                                          b: 255,
                                                                          anchor_x: 0.5,
                                                                          anchor_y: 0.5) }
  args.outputs.labels << args.state.new_cards_rect.map { |c|  c.center.merge( text: c.text,
                                                                          r: 255,
                                                                          g: 255,
                                                                          b: 255,
                                                                          anchor_x: 0.5,
                                                                          anchor_y: 0.5) }
  args.outputs.labels << args.layout.rect(row: 6, col: 8, w: 8, h: 1).center.merge( text: "Select #{args.state.free_slots} cards",
                                                                          r: 255,
                                                                          g: 255,
                                                                          b: 255,
                                                                          anchor_x: 0.5,
                                                                          anchor_y: 0.5)

    args.outputs.labels << args.layout.rect(row: 2, col: 0, w: 4, h: 1).center.merge(text: "Hand changes:")

  4.times do |i|
    god = GODS[i]
    power_diff = args.state.hand.select{|c| c.god_id == i}.sum(&:weight)
    power_diff_text = (power_diff > 0 ? "+#{power_diff}" : power_diff.to_s)

    args.outputs.labels << args.layout.rect(row: 3+i, col: 0, w: 4, h: 1).center.merge(text: "#{god&.name}: #{power_diff_text}")
  end


  check_mouse_events args
  args.state.input_locked = args.state.free_slots != 0
  change_day args if args.inputs.keyboard.key_down.space && !args.state.input_locked
end

def change_day args
  args.state.input_locked = true
  args.state.gods.each do |g| 
    g.power_diff = 0
    g.happ_diff = 0
  end

  args.state.day.num += 1
  args.state.failstate = :out_of_time if args.state.day.num > 7
  queue_souls args
  remove_deck_cards args
  take_new_cards args
  args.state.hand = []
  args.state.discard = []
  args.state.deck.shuffle!
  draw_hand args

  scene_change args, :scale
end

def prep_deck_rect args
  args.state.deck_cards_rect = []

  6.times do |i|
    col_num = 6 + i*2
    args.state.deck_cards_rect << args.layout.rect(row: 8, col: col_num, w: 2, h: 2).merge(path: :solid, r: 52, g: 52, b: 52)
  end

  6.times do |i|
    col_num = 6 + i*2
    args.state.deck_cards_rect << args.layout.rect(row: 10, col: col_num, w: 2, h: 2).merge(path: :solid, r: 52, g: 52, b: 52)
  end

  args.state.deck = args.state.deck.map {|c| c.merge(get_card_color(c)).merge(type: :deck_card, selected: true, a: 255) }

  args.state.deck_cards_rect = args.state.deck_cards_rect.each_with_index.map { |r, idx| r.merge(args.state.deck[idx].to_h) }
end

def prep_new_cards args
  args.state.new_cards = []
  tier = case args.state.day.num    
         when 1,2,3
           1
         when 4,5
           2
         when 6,7
           3
         end
  args.state.new_cards = args.state.card_list.select {|c| c.tier == tier}.shuffle[0..1]
  
  args.state.new_cards.each { |c| c.text = (c.weight < 0 ? c.weight.to_s : "+" + c.weight.to_s) }
  args.state.new_cards.each { |c| c.merge!(get_card_color(c)).merge!(type: :new_card, selected: false) }
  args.state.free_slots = (MAX_DECK_SIZE - args.state.deck.size) > 2 ? 2 : (MAX_DECK_SIZE - args.state.deck.size)
end

def prep_new_cards_rect args
  args.state.new_cards_rect = []
  args.state.new_cards_rect << args.layout.rect(row: 4, col: 10, w: 2, h: 2).merge(path: :solid, r: 52, g: 52, b: 52, a: 100).merge(args.state.new_cards[0]) if args.state.new_cards[1]
  args.state.new_cards_rect << args.layout.rect(row: 4, col: 12, w: 2, h: 2).merge(path: :solid, r: 52, g: 52, b: 52, a: 100).merge(args.state.new_cards[1]) if args.state.new_cards[1]
end

def take_new_cards args
  args.state.deck += args.state.new_cards_rect.select{|c| c.selected}.map{ |c| c.slice(:god_id, :tier, :text, :weight) }
end

def remove_deck_cards args
  cards_to_remove = args.state.deck_cards_rect.reject{|c| c.selected}.map{ |c| c.slice(:god_id, :tier, :text, :weight) }
  cards_to_remove.each do |c|
    if d_idx = args.state.deck.find_index {|dc| dc.slice(:god_id, :tier, :text, :weight) == c}
      args.state.deck.delete_at(d_idx)
    end
  end
end
