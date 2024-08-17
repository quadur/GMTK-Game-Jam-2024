require '/app/json.rb'

require '/app/scenes/scale.rb'
require '/app/scenes/end_of_day.rb'
require '/app/scenes/overworld.rb'
require '/app/scenes/out_of_time.rb'


require '/app/load_data.rb'

def tick args
  starting_state args if args.state.tick_count == 0

  check_failstate args
  scene_switcher args

end

def scene_switcher args
  case args.state.scene
  when :scale
    scene_scale_tick args
  when :end_of_day
    scene_end_of_day_tick args
  when :overworld
    scene_overworld_tick args
  when :out_of_time 
    scene_out_of_time_tick args
  end
end

def scene_change args, scene
  args.state.scene = scene
end

def check_failstate(args)
  case args.state.failstate
  when :out_of_time
    scene_change args, :out_of_time
  end
end
