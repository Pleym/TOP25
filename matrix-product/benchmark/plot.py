import pandas as pd
import matplotlib.pyplot as plt
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description="Plot performance from CSV files.")
parser.add_argument("csv_files", nargs="+", help="CSV files to plot")
args = parser.parse_args()
csv_files = args.csv_files

# extract tick values for thread counts
tick_values = pd.read_csv(csv_files[0])["threads"].tolist()

# --- GFLOP/s ---
plt.figure()
# compute max GFLOP/s across all CSVs for ylim
max_val = 0.0
for f in csv_files:
    df = pd.read_csv(f)
    label = Path(f).stem
    plt.plot(df.threads, df.gflops, marker="o", label=label)
    max_val = max(max_val, df.gflops.max())
plt.xlabel("Threads")
plt.ylabel("GFLOP/s")
plt.ylim(0, max(max_val, 0.4) * 1.1)
plt.title("GFLOP/s per thread")
plt.xticks(tick_values)
plt.axhline(0.4, color="gray", linestyle="--", label="0.4 GFLOP/s")
plt.legend()
plt.savefig("gflops.png")

# --- Speedup ---

# (with time)
plt.figure()
for f in csv_files:
    df = pd.read_csv(f)
    label = Path(f).stem
    baseline = df.time_s.iloc[0]
    speedup = baseline / df.time_s
    plt.plot(df.threads, speedup, marker="o", label=label)
plt.xlabel("Threads")
plt.ylabel("Speedup")
plt.ylim(0)
plt.title("Speedup (time)")
plt.xticks(tick_values)
plt.legend()
plt.savefig("speedup_time.png")

# (with gflops)
plt.figure()
for f in csv_files:
    df = pd.read_csv(f)
    label = Path(f).stem
    speedup = df.gflops / df.gflops.iloc[0]
    plt.plot(df.threads, speedup, marker="o", label=label)
plt.xlabel("Threads")
plt.ylabel("Speedup")
plt.ylim(0)
plt.title("Speedup (GFLOPS)")
plt.xticks(tick_values)
plt.legend()
plt.savefig("speedup_gflops.png")