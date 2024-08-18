def scene_end_of_day_tick args
  args.outputs.labels << {x: 640, y: 500, text: "DAY OVER", r: 255, alignment_enum: 1, size_enum: 10}

  4.times do |i|
    god = args.state.gods[i]
    args.outputs.labels << [640, 300+30*i+40, "#{god.name}: Power: #{god.power}(#{god.power_diff}) Happines: #{god.happiness} (#{god.happ_diff})", size_enum: -3, alignment_enum: 1]
  end


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
  draw_hand args

  scene_change args, :scale
end
