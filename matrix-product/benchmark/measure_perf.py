import os
import subprocess
import argparse
import csv
from pathlib import Path
from datetime import datetime


def run_once(executable: str, m: int, n: int, k: int, threads: int) -> float:

    env = os.environ.copy()
    env["OMP_NUM_THREADS"] = str(threads)

    try:
        completed = subprocess.run(
            [executable, str(m), str(n), str(k)],
            check=True,
            capture_output=True,
            text=True,
            env=env,
        )
    except subprocess.CalledProcessError as err:
        print(err.stderr)
        raise

    # Parse the "Time: ..." line
    time_ns = None
    for line in completed.stdout.splitlines():
        if line.startswith("Time:"):
            try:
                time_ns = int(line.split()[1])
            except (IndexError, ValueError):
                pass
            break

   
    return time_ns / 1e9  # convert nanoseconds → seconds


def compute_flops(m: int, n: int, k: int, time_s: float) -> float:
    """Return FLOP/s for a matrix‑matrix product C = A·B of sizes (m×k)·(k×n)."""
    operations = 2 * m * n * k  # one multiply and one add per FMA
    return operations / time_s


def benchmark(
    executable: str,
    m: int,
    n: int,
    k: int,
    min_threads: int = 1,
    max_threads: int | None = None,
):
    if max_threads is None:
        max_threads = os.cpu_count() or 1

    print(f"Benchmarking {executable} for M={m}, N={n}, K={k}")
    print("threads, time[s], GFLOP/s")

    results = []
    for threads in range(min_threads, max_threads + 1):
        t_s = run_once(executable, m, n, k, threads)
        gflops = compute_flops(m, n, k, t_s) / 1e9
        print(f"{threads}, {t_s:.6f}, {gflops:.3f}")
        results.append((threads, t_s, gflops))

    return results


def write_csv(results, filepath: Path, m: int, n: int, k: int):
    header = ["threads", "time_s", "gflops"]
    first_write = not filepath.exists()
    with filepath.open("a", newline="") as fp:
        writer = csv.writer(fp)
        if first_write:
            writer.writerow(["date", "M", "N", "K", *header])
        date_str = datetime.now().isoformat(timespec="seconds")
        for row in results:
            writer.writerow([date_str, m, n, k, *row])


def main():
    parser = argparse.ArgumentParser(description="Automate performance measurements for the matrix‑product benchmark.")
    parser.add_argument("M", type=int, help="Number of rows of A / C")
    parser.add_argument("N", type=int, help="Number of columns of B / C")
    parser.add_argument("K", type=int, help="Number of columns of A / rows of B")
    parser.add_argument(
        "--exe",
        default=str(Path(__file__).resolve().parent.parent / "build" / "src" / "top.matrix_product"),
        help="Path to the compiled matrix‑product executable.",
    )
    parser.add_argument("--min-threads", type=int, default=1, help="Minimum number of OpenMP threads to test.")
    parser.add_argument("--max-threads", type=int, default=None, help="Maximum number of OpenMP threads to test.")
    parser.add_argument("--csv", type=Path, help="Append results to the specified CSV file.")

    args = parser.parse_args()
    results = benchmark(args.exe, args.M, args.N, args.K, args.min_threads, args.max_threads)

    if args.csv:
        write_csv(results, args.csv, args.M, args.N, args.K)


if __name__ == "__main__":
    main()
