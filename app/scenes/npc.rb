def scene_npc_tick args
  day_clock args
  args.outputs.sprites << [args.state.day.bar, args.state.npc_buttons]
  args.outputs.labels << [args.state.npc_labels]

  if args.state.current_soul
    args.outputs.labels << {x: 640, y: 700, text: args.state.current_soul.name, r: 0, g:102, b:102, alignment_enum: 1, size_enum: 10}

    args.outputs.labels << [640, 500+30*2+40, "Weight: #{args.state.current_soul.weight}", size_enum: -3, alignment_enum: 1]
    args.outputs.labels << [640, 500+30*1+40, "Traits: #{args.state.current_soul.traits.map(&:name).to_a.join(', ')}", size_enum: -3, alignment_enum: 1]
    args.outputs.labels << [640, 500+30*0+40, "Alignment", size_enum: -3, alignment_enum: 1]
    args.state.current_soul.alignment.to_a.each_with_index do |al, i|
      args.outputs.labels << {x: 640, y: 500-20*(i+1)+40, text: "#{GODS[al].name}", size_enum: -3, alignment_enum: 1}.merge(get_color(al))
    end
  end


  check_day_clock args
  check_mouse_events args
end
