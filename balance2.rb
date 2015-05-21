# coding: utf-8

# balance task
# 4ms 周期で倒立制御を行う

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
		EV3RT::LCD.print("b log error!!")
	else
		EV3RT::LCD.print("b log ok")
	end
end


#for log
logger = EV3RT::Serial.new(EV3RT::SIO_PORT_BT)

led = EV3RT::LED.new()

colorSensor = EV3RT::ColorSensor.new(EV3RT::PORT_3)
sonarSensor = EV3RT::SonarSensor.new(EV3RT::PORT_2)
gyroSensor = EV3RT::GyroSensor.new(EV3RT::PORT_4)

leftMotor = EV3RT::Motor.new(EV3RT::PORT_C, EV3RT::LARGE_MOTOR)
rightMotor = EV3RT::Motor.new(EV3RT::PORT_B, EV3RT::LARGE_MOTOR)
tailMotor = EV3RT::TailMotor.new(EV3RT::PORT_A, EV3RT::LARGE_MOTOR)
tailMotor.p_gain = P_GAIN
tailMotor.pwm_abs_max = PWM_ABS_MAX
clock = EV3RT::Clock.new()

#走行モータエンコーダリセット
leftMotor.reset
rightMotor.reset

#ジャイロセンサリセット
gyroSensor.reset

#バランサリセット
##EV3RT::Balancer.reset

balancer = EV3RT::Balancer.new()
balancer.right_motor = rightMotor
balancer.left_motor = leftMotor
balancer.gyro = gyroSensor
balancer.reset
balancer.gyro_direction = -1	# ジャイロセンサーが逆向きのため。通常は省略可

#走行可能(LEDは緑)
led.on(EV3RT::LED_GREEN)

EV3RT::Task.sleep


loop do
  forward = 30	# 前進命令
  color = colorSensor.brightness	# log用に一度変数に入れる
  if color >= (LIGHT_WHITE + LIGHT_BLACK)/2
#  if colorSensor.brightness >= (LIGHT_WHITE + LIGHT_BLACK)/2
    turn = 20	# 左旋回命令
  else
    turn = -20	# 右旋回命令
  end

   pwm_left, pwm_right, gyro, motor_r, motor_l, volt = balancer.calculate_auto(forward, turn, GYRO_OFFSET)
   leftMotor.pwm = pwm_left
   rightMotor.pwm = pwm_right

#	msg = "time:#{clock.now},c:#{color},lpwm:#{pwm_left},rpwm:#{pwm_right}\r\n"
	msg = "time:#{clock.now},c:#{color},g:#{gyro},rm:#{motor_r},lm:#{motor_l},rpwm:#{pwm_right},lpwm:#{pwm_left},v:#{volt}\r\n"
	log(logger, msg)

	EV3RT::Task.sleep

end #loop


