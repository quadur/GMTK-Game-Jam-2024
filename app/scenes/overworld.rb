def scene_overworld_tick args
  day_clock args
  args.outputs.sprites << [args.state.day.bar, args.state.overworld_buttons]
  args.outputs.labels << args.state.overworld_labels

  args.outputs.labels << {x: 640, y: 700, text: "OVERWORLD", r: 0, g:102, b:102, alignment_enum: 1, size_enum: 10}
  args.outputs.labels << [10, 710, "framerate: #{args.gtk.current_framerate.round}"]

  args.state.afterlife.each do |af|
    if (god = args.state.gods.find { |g| g.god_id == af.god_id })
      god.power_diff = af.souls.sum {|s| s.aff_change }

      god.happ_diff = af.souls.count {|s| s.alignment.include?(god.god_id)}
    end
  end

  4.times do |i|
    god = args.state.gods[i]
    args.outputs.labels << [640, 500+30*i+40, "#{god.name}: Power: #{god.power}(#{god.power_diff}) Happines: #{god.happiness} (#{god.happ_diff})", size_enum: -3, alignment_enum: 1]
  end
  check_day_clock args


  check_mouse_events args
end
