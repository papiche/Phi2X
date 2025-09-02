import RPi.GPIO as GPIO
import time
import math

# === CONFIGURATION ===
PWM_PIN = 18
FREQ_BASE = 1000  # Hz (f₀)
PHI = (1 + 5**0.5) / 2
n = 2.0            # curseur Φⁿ
m = 2.0            # curseur 2ᵐ
DUTY_CYCLE = 50    # %

# === SETUP GPIO ===
GPIO.setmode(GPIO.BCM)
GPIO.setup(PWM_PIN, GPIO.OUT)
pwm = GPIO.PWM(PWM_PIN, FREQ_BASE)
pwm.start(DUTY_CYCLE)

try:
    while True:
        # Calcul des deux fréquences
        f_phi = FREQ_BASE * (PHI ** n)
        f_two = FREQ_BASE * (2 ** m)

        # Fusion simple (moyenne pondérée ou autre logique possible)
        f_mix = (f_phi + f_two) / 2

        print(f"f₀ = {FREQ_BASE} Hz | Φⁿ = {f_phi:.1f} Hz | 2ᵐ = {f_two:.1f} Hz → f = {f_mix:.1f} Hz")
        pwm.ChangeFrequency(f_mix)
        time.sleep(0.05)

except KeyboardInterrupt:
    print("Arrêté.")
    pwm.stop()
    GPIO.cleanup()

