def tick args
  starting_state args if args.state.tick_count == 0

  args.outputs.sprites << [args.state.scale.left, args.state.scale.right, args.state.day.bar]

  check_failstate args
  day_clock args
  shift_soul args
  move_scales args

  regenerate_soul args if args.inputs.keyboard.key_down.r

#  args.state.scale.target_value = rand(100) if args.state.scale.delta == args.state.scale.target_value
  args.outputs.labels << [10, 710, "framerate: #{args.gtk.current_framerate.round}"]
  args.outputs.labels << [10, 710-30*1, "current soul: #{args.state.current_soul}"]
  args.outputs.labels << [10, 710-30*2, "souls: #{args.state.souls}"]
  args.outputs.labels << [10, 710-30*3, "Day left (s): #{args.state.day.time}"]
end

def starting_state args
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
    angle: 0
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
    a: 100
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

  args.state.scale.delta ||= 0
  args.state.scale.target_value ||= 0

  args.state.day.day_length ||= 10
  args.state.day.time ||= args.state.day.day_length

  args.state.souls = []
  args.state.current_soul = nil
  5.times { generate_soul args }
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
end

SOUL_TEMPLATE = { 
  name: 'Seba',
  deeds: []
}

def generate_soul args
  soul = SOUL_TEMPLATE.copy
  (1+rand(4)).times { soul.deeds << rand(25)}
  soul.name += " #{rand(1000)}"
  soul.weight = soul.deeds.sum

  args.state.souls << soul
  puts soul
end

def shift_soul args
  if args.state.current_soul.nil? && args.state.souls.any?
    args.state.current_soul = args.state.souls.shift
    args.state.scale.target_value = args.state.current_soul.weight
  end
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

def check_failstate args
  if args.state.day.time <= 0
    args.state.failstate = 1
  end

  case args.state.failstate
  when 1
    args.outputs.labels << {x: 640, y: 500, text: "DAY OVER", r: 255, alignment_enum: 1, size_enum: 10}
  end
end
