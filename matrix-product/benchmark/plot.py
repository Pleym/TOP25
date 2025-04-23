import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("result.csv", names = ["date", "M", "N", "K", "threads", "time_s", "gflops"])


# --- GFLOP/s ---
plt.figure()
plt.plot(df.threads, df.gflops, marker="o")
plt.xlabel("Threads")
plt.ylabel("GFLOP/s")
plt.ylim(0)
plt.title("GFLOP/s per thread")
plt.xscale("log",base=2)
plt.savefig("gflops.png")

# --- Speedup ---

# (with time)
plt.figure()
speedup = df.time_s.iloc[0] / df.time_s
plt.plot(df.threads, speedup, marker="o")
plt.xlabel("Threads")
plt.ylabel("Speedup")
plt.ylim(0)
plt.title("Speedup")
plt.xscale("log",base=2)
plt.savefig("speedup_time.png")

# (with gflops)
plt.figure()
speedup = df.gflops / df.gflops.iloc[0]
plt.plot(df.threads, speedup, marker="o")
plt.xlabel("Threads")
plt.ylabel("Speedup")
plt.ylim(0)
plt.title("Speedup")
plt.xscale("log",base=2)
plt.savefig("speedup_gflops.png")