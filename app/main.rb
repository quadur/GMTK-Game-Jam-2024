require '/app/json.rb'

require '/app/scenes/scale.rb'
require '/app/scenes/end_of_day.rb'
require '/app/scenes/overworld.rb'
require '/app/scenes/out_of_time.rb'
require '/app/scenes/npc.rb'

require '/app/load_data.rb'

MAX_DECK_SIZE = 12

def tick args

  if Kernel.tick_count == 0
    args.audio[:bg_music] = { input: "sounds/background1.mp3", looping: true }
    args.audio.volume = 0.1
    args.state.audio_button = VOLUME_SPRITE.copy
  end

  args.outputs.sprites << args.state.audio_button

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
  when :npc
    scene_npc_tick args
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

def change_volume args, event
  case event.volume
  when 0.1
    args.state.audio_button.merge!(path: "/sprites/volume/2.png", volume: 0.3)
    args.audio.volume = 0.3
  when 0.3
    args.state.audio_button.merge!(path: "/sprites/volume/0.png", volume: 0.0)
    args.audio.volume = 0.0
  else
    args.state.audio_button.merge!(path: "/sprites/volume/1.png", volume: 0.1)
    args.audio.volume = 0.1
  end
end
