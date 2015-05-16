# coding: utf-8

TAIL_ANGLE_DOWN = 93	# 尻尾を下げた状態のときの角度[度]
#TAIL_ANGLE_DOWN = 80	# 尻尾を下げた状態のときの角度[度]
TAIL_ANGLE_UP = 3	# 尻尾を上げた状態のときの角度[度]
GYRO_OFFSET = 0         # ジャイロセンサオフセット値(角速度0[deg/sec]時)
LIGHT_WHITE = 40	# 白色の光センサ値
LIGHT_BLACK = 0		# 黒色の光センサ値

P_GAIN = 2.5            # 完全停止用モータ制御比例係数
PWM_ABS_MAX = 60        # 完全停止用モータ制御PWM絶対最大値

def log(logger, msg)
	value = logger.write(msg)
	if !value
		EV3RT::LCD.print("log error!!")
	else
		EV3RT::LCD.print("log ok")
	end
end

touchSensor = EV3RT::TouchSensor.new(EV3RT::PORT_1)
colorSensor = EV3RT::ColorSensor.new(EV3RT::PORT_3)
sonarSensor = EV3RT::SonarSensor.new(EV3RT::PORT_2)
gyroSensor = EV3RT::GyroSensor.new(EV3RT::PORT_4)


leftMotor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
rightMotor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)
tailMotor = EV3RT::TailMotor.new(EV3RT::PORT_A, EV3RT::LARGE_MOTOR)
tailMotor.p_gain = P_GAIN
tailMotor.pwm_abs_max = PWM_ABS_MAX
clock = EV3RT::Clock.new()

#for log
logger = EV3RT::Serial.new(EV3RT::SIO_PORT_BT)

# LCD 
led = EV3RT::LED.new()
led.on(EV3RT::LED_ORANGE)

# 初期処理だけして寝かす
EV3RT::Task.active(EV3RT::BALANCE_TASK_ID)

EV3RT::LCD.print("EV3way sample mruby cyclick ver.")

# スタート待機
loop do
#  tailMotor.control(TAIL_ANGLE_DOWN)

  if touchSensor.pressed?
    break
	else
	
  end

  clock.sleep(10)

end	# loop end

EV3RT::Task.start_cyclic(EV3RT::BALANCE_CYC_ID)
EV3RT::LCD.print("sleep main task.")

# back ボタンで終了指示があるまでおやすみ
EV3RT::Task.sleep


leftMotor.stop
rightMotor.stop

led.on(EV3RT::LED_RED)


