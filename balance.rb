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
EV3RT::Balancer.reset

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

   leftMotorAngle = leftMotor.count
   rightMotorAngle = rightMotor.count

   gyro = -1 * gyroSensor.rate	#ジャイロセンサーの向きが逆のため符号反転
   volt = EV3RT::Battery.batteryVoltage

   pwm_left, pwm_right = EV3RT::Balancer.calculate(forward, turn, gyro, GYRO_OFFSET,
                                            leftMotorAngle, rightMotorAngle, volt)
   leftMotor.pwm = pwm_left
   rightMotor.pwm = pwm_right

	msg = "time:#{clock.now},c:#{color},g:#{gyro},rm:#{rightMotorAngle},lm:#{leftMotorAngle},lpwm:#{pwm_left},rpwm:#{pwm_right},v:#{volt}\r\n"
	log(logger, msg)

	EV3RT::Task.sleep

end #loop


