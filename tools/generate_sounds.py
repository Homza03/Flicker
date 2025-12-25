import os
import wave
import math
import struct
import random
import os
import wave
import math
import struct
import random

os.makedirs('assets/sounds', exist_ok=True)

SAMPLE_RATE = 44100

def float_to_int16(samples):
    out = []
    for s in samples:
        v = max(-1.0, min(1.0, s))
        out.append(int(v * 32767))
    return out

def write_wav(path, samples):
    ints = float_to_int16(samples)
    with wave.open(path, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(struct.pack('<' + ('h'*len(ints)), *ints))

def lowpass(samples, cutoff=8000):
    rc = 1.0 / (2 * math.pi * cutoff)
    dt = 1.0 / SAMPLE_RATE
    alpha = dt / (rc + dt)
    out = []
    prev = 0.0
    for s in samples:
        prev = prev + alpha * (s - prev)
        out.append(prev)
    return out

def gen_coin():
    duration = 0.18
    N = int(SAMPLE_RATE * duration)
    out = [0.0] * N
    base = 1200.0
    for n in range(N):
        t = n / SAMPLE_RATE
        env = math.exp(-12 * t)
        glide = base * (1.0 + 0.06 * t)
        s = 0.0
        s += 0.75 * math.sin(2 * math.pi * glide * t)
        s += 0.35 * math.sin(2 * math.pi * (glide * 2.02) * t)
        s += 0.12 * math.sin(2 * math.pi * (glide * 3.99) * t)
        s += 0.06 * (random.random() * 2 - 1) * math.exp(-30 * t)
        out[n] = env * s
    out = lowpass(out, cutoff=10000)
    return out

def gen_powerup():
    duration = 0.6
    N = int(SAMPLE_RATE * duration)
    out = [0.0] * N
    f0 = 500.0
    f1 = 2600.0
    for n in range(N):
        t = n / SAMPLE_RATE
        frac = t / duration
        freq = f0 * (1 - frac) + f1 * frac + 40 * math.sin(2 * math.pi * 2.5 * t)
        env = (math.sin(math.pi * frac) ** 2) * 0.95
        s = 0.0
        s += 0.6 * math.sin(2 * math.pi * freq * t)
        s += 0.28 * math.sin(2 * math.pi * (freq * 1.99) * t)
        s += 0.12 * math.sin(2 * math.pi * (freq * 3.01) * t)
        out[n] = env * s
    delay = int(0.018 * SAMPLE_RATE)
    for i in range(delay, N):
        out[i] += 0.18 * out[i - delay]
    out = lowpass(out, cutoff=11000)
    return out

def gen_shield_hit():
    duration = 0.36
    N = int(SAMPLE_RATE * duration)
    out = [0.0] * N
    base = 420.0
    ratios = [1.0, 1.9, 2.7, 3.4, 4.2]
    for n in range(N):
        t = n / SAMPLE_RATE
        env = math.exp(-7 * t)
        s = 0.0
        for r in ratios:
            s += (0.5 / len(ratios)) * math.sin(2 * math.pi * (base * r + 20 * math.sin(2 * math.pi * 80 * t)) * t)
        s += 0.28 * (random.random() * 2 - 1) * math.exp(-35 * t)
        out[n] = env * s
    out = lowpass(out, cutoff=12000)
    return out

def gen_jump():
    duration = 0.22
    N = int(SAMPLE_RATE * duration)
    out = [0.0] * N
    for n in range(N):
        t = n / SAMPLE_RATE
        env = math.exp(-6 * t)
        s = 0.9 * math.sin(2 * math.pi * 100 * t) * math.exp(-2.2 * t)
        s += 0.12 * (random.random() * 2 - 1) * math.exp(-25 * t)
        out[n] = env * s
    out = lowpass(out, cutoff=5000)
    return out

def gen_crash():
    duration = 0.9
    N = int(SAMPLE_RATE * duration)
    noise_sig = [random.uniform(-1, 1) * math.exp(-3 * (i / N)) for i in range(N)]
    out = lowpass(noise_sig, cutoff=7000)
    for n in range(N):
        t = n / SAMPLE_RATE
        out[n] += 0.45 * math.sin(2 * math.pi * 70 * t) * math.exp(-1.1 * t)
    for i in range(N):
        out[i] *= (1 - (i / N) ** 1.2)
    return out

if __name__ == '__main__':
    print('Generating improved sounds...')
    write_wav('assets/sounds/coin.wav', gen_coin())
    write_wav('assets/sounds/powerup.wav', gen_powerup())
    write_wav('assets/sounds/shield_hit.wav', gen_shield_hit())
    write_wav('assets/sounds/jump.wav', gen_jump())
    write_wav('assets/sounds/crash.wav', gen_crash())
    print('WAV files written to assets/sounds/')

