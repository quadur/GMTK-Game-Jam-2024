def scene_scale_tick args
  day_clock args
  shift_soul args unless args.state.input_locked
  move_scales args

  release_soul args if args.inputs.keyboard.key_down.r && !args.state.input_locked

  args.outputs.sprites << [args.state.scale.left, args.state.scale.right, args.state.day.bar, args.state.afterlife]

  check_day_clock args

  args.outputs.labels << [10, 710, "framerate: #{args.gtk.current_framerate.round}"]
  args.outputs.labels << [300, 710, "Day: #{args.state.day.num}"]
  args.outputs.labels << [10, 710-30*1, "current soul: #{args.state.current_soul}"]
  args.outputs.labels << [10, 710-30*2, "souls left: #{args.state.souls.count}"]
  args.outputs.labels << [10, 710-30*3, "souls: #{args.state.souls}"]
  args.outputs.labels << [10, 710-30*4, "Time left (s): #{args.state.day.time}"]

  4.times do |i|
    afterlife = args.state.afterlife[i]
    args.outputs.labels << [10, 200+100*i+40, "#{afterlife.name}: #{afterlife.threshold}", size_enum: -3]
    args.outputs.labels << [10, 200+100*i+20, "#{afterlife.souls.map{|s| {s[:name] => {w: s[:weight], aff_chng: s[:aff_change], a: s[:alignment], aff: s[:affinity]}}}}", size_enum: -3]
  end
end

def starting_state args
  args.state.scene ||= :scale

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
  args.state.day.day_length ||= 10
  args.state.day.time ||= args.state.day.day_length

  args.state.gods ||= GODS.copy

  args.state.souls ||= []
  args.state.current_soul = nil
  queue_souls args
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

  soul.name += " #{rand(1000)}"
  soul.weight = soul.deeds.sum
  soul.px_weight = soul.weight * (300/24 + 5)

  soul.traits = traits.map do |t|
    TRAITS.select {|tr| tr.tier == t}.sample.copy
  end

  soul.alignment = soul.traits.map(&:alignment).flatten.tally.sort_by{ |k, v| v}.last(2).map(&:first)
  soul.affinity = soul.traits.map(&:affinity).transpose.map(&:sum)

  args.state.souls << soul
  puts soul
end

def shift_soul args
  if args.state.current_soul.nil? && args.state.souls.any?
    args.state.current_soul = args.state.souls.shift
    args.state.scale.target_value = args.state.current_soul.px_weight.round
  end
end

def release_soul args
  soul = args.state.current_soul
  if (afterlife = args.state.afterlife.find{ |a| a.threshold.include?(args.state.current_soul.weight)}) && soul
    soul.aff_change = soul.affinity[afterlife.god_id] 
    afterlife.souls << soul
  end
  args.state.current_soul = nil
  reset_scales args
end

def regenerate_soul args
  args.state.current_soul = nil
  generate_soul args if args.state.souls.none?
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
  if args.state.day.time <= 0 && args.state.souls.none?
    resolve_day args
    reset_scale_scene args
    scene_change args, :end_of_day
  end
end

def resolve_day args
  args.state.afterlife.each do |af|
    if (god = args.state.gods.find { |g| g.god_id == af.god_id })
      god.power_diff = af.souls.sum {|s| s.aff_change }
      god.power += god.power_diff 
      
      god.happ_diff = af.souls.count {|s| s.alignment.include?(god.god_id)}
      god.happiness += god.happ_diff
    end
  end
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

