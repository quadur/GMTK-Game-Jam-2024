def scene_scale_tick args
  day_clock args
  shift_soul args unless args.state.input_locked
  move_scales args

  release_soul args if args.inputs.keyboard.key_down.space && !args.state.input_locked

  args.outputs.sprites << [args.state.scale.left, args.state.scale.right, args.state.day.bar, args.state.afterlife]

  check_day_clock args

  check_mouse_events args

  args.outputs.labels << [10, 710, "framerate: #{args.gtk.current_framerate.round}"]
  args.outputs.labels << [300, 710, "Day: #{args.state.day.num}"]
  args.outputs.labels << [10, 710-30*1, "souls left: #{args.state.souls.count}"]
  args.outputs.labels << [10, 710-30*2, "Time left (s): #{args.state.day.time}"]

  args.outputs.sprites << args.state.scale_buttons
  args.outputs.labels << args.state.scale_buttons.map{|b| b.center.merge(text: b.text, r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5) }


  4.times do |i|
    afterlife = args.state.afterlife[i]
    args.outputs.labels << [10, 200+100*i+40, "#{afterlife.name}: #{afterlife.threshold}", size_enum: -3]
    args.outputs.labels << [10, 200+100*i+20, "#{afterlife.souls.count}", size_enum: -3]
  end

  args.state.cards_rect_active = args.state.cards_rect.each_with_index.map { |r, idx| r.merge(path: :solid, r: 52, g: 52, b: 52).merge(args.state.hand[idx].to_h).merge({idx: idx})}
  args.outputs.sprites << args.state.cards_rect_active

  args.outputs.labels << args.state.cards_rect.each_with_index.map {|c, idx|  c.center.merge(text: args.state.hand[idx].to_h.text,
                                                                                        r: 255,
                                                                                        g: 255,
                                                                                        b: 255,
                                                                                        anchor_x: 0.5,
                                                                                        anchor_y: 0.5) }

#  args.outputs.primitives << args.layout.debug_primitives

end

def starting_state args
  args.state.scene ||= :scale

  args.state.scale_buttons ||= []
  args.state.scale_buttons << args.layout.rect(row: 11, col: 1, w: 5, h: 1).merge(path: :solid, r: 52, g: 73, b: 94, a: 255).merge(type: :change_scene, target: :npc)
  args.state.scale_buttons << args.layout.rect(row: 11, col: 18, w: 5, h: 1).merge(path: :solid, r: 52, g: 73, b: 94, a: 255).merge(type: :change_scene, target: :overworld, text: 'GODS')


  args.state.npc_buttons ||= []
  args.state.npc_labels ||= []
  args.state.npc_buttons << args.layout.rect(row: 11, col: 1, w: 3, h: 1).merge(path: :solid, r: 52, g: 73, b: 94, a: 255).merge(type: :change_scene, target: :scale, text: 'Back')
  args.state.npc_labels << args.state.npc_buttons.map{|b| b.center.merge(text: b.text, r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5) } 

  args.state.overworld_buttons ||= []
  args.state.overworld_labels ||= []
  args.state.overworld_buttons << args.layout.rect(row: 11, col: 1, w: 3, h: 1).merge(path: :solid, r: 52, g: 73, b: 94, a: 255).merge(type: :change_scene, target: :scale, text: 'Back')
  args.state.overworld_labels << args.state.overworld_buttons.map{|b| b.center.merge(text: b.text, r: 255, g: 255, b: 255, anchor_x: 0.5, anchor_y: 0.5) } 


  args.state.scale.left ||= {
    x: 400,
    y: 350,
    w: 100,
    h: 10,
    path: :solid,
    r: 50,
    g: 50,
    b: 50,
    a: 100,
    angle: 0,
    start_y: 350
  }

  args.state.scale.right ||= {
    x: 1280-500,
    y: 350,
    w: 100,
    h: 10,
    path: :solid,
    r: 50,
    g: 50,
    b: 50,
    a: 100,
    start_y: 350
  }

  args.state.day.bar ||= { 
    x: 1100,
    y: 300,
    w: 40,
    h: 300,
    r: 0,
    g: 0,
    b: 100,
    start_h: 300
  }

  args.state.afterlife ||= []

  args.state.afterlife <<  {
    x: 0,
    y: 150 + 5,
    w: 400,
    h: 10,
    r: 100,
    g: 0,
    b: 0,
    souls: [],
    threshold: 7..Float::INFINITY,
    god_id: 0,
    name: GODS.find {|g| g.god_id == 0}.name
  }

  args.state.afterlife << {
    x: 0,
    y: 150 + 100 * 1 + 5 ,
    w: 400,
    h: 10,
    r: 100,
    g: 0,
    b: 0,
    souls: [],
    threshold: 1..6,
    god_id: 1,
    name: GODS.find {|g| g.god_id == 1}.name
  }

  args.state.afterlife << {
    x: 0,
    y: 150 + 100 * 2,
    w: 400,
    h: 10,
    r: 100,
    g: 0,
    b: 0,
    souls: [],
    threshold: -6..-1,
    god_id: 2,
    name: GODS.find {|g| g.god_id == 2}.name
  }

  args.state.afterlife << {
    x: 0,
    y: 150 + 100 * 3 + 5,
    w: 400,
    h: 10,
    r: 100,
    g: 0,
    b: 0,
    souls: [],
    threshold: -Float::INFINITY..-7,
    god_id: 3,
    name: GODS.find {|g| g.god_id == 3}.name
  }

  args.state.scale.delta ||= 0
  args.state.scale.target_value ||= 0

  args.state.day.num ||= 1
  args.state.day.day_length ||= 60
  args.state.day.time ||= args.state.day.day_length

  args.state.gods ||= GODS.copy

  args.state.souls ||= []
  args.state.current_soul = nil
  queue_souls args

  args.state.deck ||= BASE_DECK.copy
  args.state.card_list ||= CARD_LIST.copy.shuffle
  shuffle_deck args
  args.state.hand ||= []
  args.state.discard ||= []
  draw_hand args


  args.state.cards_rect ||= [args.layout.rect(row: 10, col: 8, w: 2, h: 2), args.layout.rect(row: 10, col: 10, w: 2, h: 2), args.layout.rect(row: 10, col: 12, w: 2, h: 2), args.layout.rect(row: 10, col: 14, w: 2, h: 2)]
end

def move_scales args  
  if args.state.scale.delta < args.state.scale.target_value
    args.state.scale.left.y -= 1
    args.state.scale.right.y += 1
    args.state.scale.delta += 1
  elsif args.state.scale.delta > args.state.scale.target_value
    args.state.scale.left.y += 1
    args.state.scale.right.y -= 1
    args.state.scale.delta -= 1
  end
  args.state.input_locked = false if args.state.scale.delta == args.state.scale.target_value && args.state.scale.delta == 0
end

def reset_scales args
  args.state.input_locked = true
  args.state.scale.target_value = 0
end

SOUL_TEMPLATE = { 
  name: 'Seba',
  deeds: [],
  traits: [],
  alignment: [],
  affinity: []
}

PX_WEIGHT_MOD = (300/24 + 5)

def generate_soul args

  trait_no = case args.state.day.num
             when 1
               1
             when 2, 3
               2
             when 4, 5
               3
             when 6, 7 
               4
             end

  traits = case trait_no
                when 1
                  [1]
                when 2
                  [[1, 2], [2, 2]].sample
                when 3
                  [1, 2, 2]
                when 4 
                  [1, 2, 2, 3]
                end

  soul = SOUL_TEMPLATE.copy
  
  (1+rand(4)).times { soul.deeds << ((1+rand(3)) * (rand(2).odd? ? -1 : 1) )}

  soul.name = NAMES.sample
  soul.weight = soul.deeds.sum
  soul.px_weight = soul.weight * PX_WEIGHT_MOD

  soul.traits = traits.map do |t|
    TRAITS.select {|tr| tr.tier == t}.sample.copy
  end

  soul.alignment = soul.traits.map(&:alignment).flatten.tally.sort_by{ |k, v| v}.last(2).map(&:first)
  soul.affinity = soul.traits.map(&:affinity).transpose.map(&:sum)

  args.state.souls << soul
end

def shift_soul args
  if args.state.current_soul.nil? && args.state.souls.any?
    args.state.current_soul = args.state.souls.shift
    args.state.scale.target_value = args.state.current_soul.px_weight.round
  end
  
  name = args.state.current_soul.nil? ? 'none' : args.state.current_soul.name
  args.state.scale_buttons.find {|b| b.type == :change_scene && b.target == :npc}.text = "Details: #{name}"

end

def release_soul args
  soul = args.state.current_soul
  if (afterlife = args.state.afterlife.find{ |a| a.threshold.include?(args.state.current_soul.weight)}) && soul
    soul.aff_change = soul.affinity[afterlife.god_id] 
    afterlife.souls << soul
  end

  args.state.current_soul = nil
  name = args.state.current_soul.nil? ? 'none' : args.state.current_soul.name
  args.state.scale_buttons.find {|b| b.type == :change_scene && b.target == :npc}.text = "Details: #{name}"
  reset_scales args
  draw_hand args
end

def regenerate_soul args
  args.state.current_soul = nil
  generate_soul args if args.state.souls.none?
end

def shuffle_deck args
  args.state.deck.shuffle!
end

def draw_hand args
  max_hand_size = 4
  hand_size = args.state.hand.count
  if (hand_diff = max_hand_size - hand_size) > 0
    if hand_diff >= args.state.deck.count
      args.state.deck.unshift *args.state.discard.shuffle
      args.state.discard = []
    end
    
    hand_diff.times do 
      card = args.state.deck.pop 
      card_color = get_card_color card
      args.state.hand << card.merge(card_color).merge({type: :card})
    end
  end
end

def get_card_color card
  get_color card.god_id
end

def get_color god_id
  case god_id
  when 3
    { r: 182, g: 215, b: 168 }
  when 2
    { r: 111, g: 168, b: 220 }
  when 1 
    { r: 221, g: 126, b: 107 }
  when 0 
    { r: 166, g: 77, b: 121 }
  else 
    { r: 147, g: 149, b: 151 }
  end
end

def day_clock args
  if (args.state.tick_count % 60) == 0 && args.state.day.time > 0
    args.state.day.time -= 1 
    update_day_clock_bar args
  end
end

def update_day_clock_bar args
  bar_percent = args.state.day.bar.start_h / 100.to_f
  time_percent = (args.state.day.time * 100.to_f) / args.state.day.day_length 
  args.state.day.bar.h = time_percent * bar_percent
end

def check_day_clock args
  if args.state.day.time <= 0 || (args.state.souls.none? && args.state.current_soul.nil?)
    resolve_day args
    reset_scale_scene args
    prep_deck_rect args
    prep_new_cards args
    prep_new_cards_rect args
    scene_change args, :end_of_day
  end
end

def resolve_day args
  args.state.afterlife.each do |af|
    if (god = args.state.gods.find { |g| g.god_id == af.god_id })
      god.power_diff = af.souls.sum {|s| s.aff_change }
      god.power_diff += args.state.hand.select{|c| c.god_id == god.god_id }.sum(&:weight)

      god.power += god.power_diff 
      
      god.happ_diff = af.souls.count {|s| s.alignment.include?(god.god_id)}
      god.happiness += god.happ_diff
    end
  end

  reset_deck args
end

def reset_scale_scene args
  args.state.scale.left.y = args.state.scale.left.start_y
  args.state.scale.right.y = args.state.scale.left.start_y
  args.state.day.bar.h =  args.state.day.bar.start_h

  args.state.scale.delta = 0
  args.state.scale.target_value = 0
  args.state.day.time = args.state.day.day_length

  args.state.souls = []
  args.state.current_soul = nil

  args.state.afterlife.each do |af|
    af.souls = []
  end
end

def queue_souls args
  souls_num = case args.state.day.num 
              when 1,2 
                4
              when 3,4
                6
              when 5,6
                8
              when 7 
                10
              end
  souls_num.times { generate_soul args }
end

def check_mouse_events args
  if args.inputs.mouse.click
    interactables = case args.state.scene
                    when :scale
                      args.state.cards_rect_active + args.state.scale_buttons
                    when :end_of_day
                      args.state.new_cards_rect + args.state.deck_cards_rect
                    when :npc
                      args.state.npc_buttons
                    when :overworld
                      args.state.overworld_buttons
                    end
    interactables += [args.state.audio_button]
    if (event = args.geometry.find_intersect_rect args.inputs.mouse, interactables)
      case event.type
      when :card
        if args.state.current_soul
          args.state.current_soul.weight += event.weight
          args.state.scale.target_value += (event.weight * PX_WEIGHT_MOD).round
          
          if event.god_id > -1
              enemy_id = case event.god_id 
                         when 0
                           2
                         when 1
                           3
                         when 2
                           0
                         when 3
                           1
                         end

              args.state.current_soul.alignment |= [event.god_id] unless args.state.current_soul.alignment.delete(enemy_id)
          end

          args.state.discard << args.state.hand.delete_at(event.idx)
        end
      when :new_card, :deck_card
        alpha = ( event.a == 255 ? 100 : 255)
        if event.selected 
          args.state.free_slots += 1
          event.merge!(a: alpha, selected: false)
        elsif !event.selected && args.state.free_slots > 0
          args.state.free_slots -= 1
          event.merge!(a: alpha, selected: true)
        end
      when :change_scene
        scene_change args, event.target
      when :sound
        change_volume args, event
      end
    end
  end
end

def reset_deck args
  args.state.deck += args.state.hand + args.state.discard
  args.state.deck = args.state.deck.sort_by(&:weight).reverse
end
