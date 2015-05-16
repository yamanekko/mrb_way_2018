# coding: utf-8

# watch task
# back ボタンが押されたか監視する

def log(logger, msg)
	value = logger.write(msg)
	if !value
		EV3RT::LCD.print("b log error!!")
	else
		EV3RT::LCD.print("b log ok")
	end
end


#for log
logger = EV3RT::Serial.new(EV3RT::SIO_PORT_BT)

led = EV3RT::LED.new()
back_button = EV3RT::Button.new(EV3RT::BACK_BUTTON)

EV3RT::Task.sleep

# バックボタンで終了を検知
loop do
  if back_button.pressed?
   break
  end

EV3RT::Task.sleep
end #loop

EV3RT::Task.wakeup(EV3RT::MAIN_TASK_ID)

