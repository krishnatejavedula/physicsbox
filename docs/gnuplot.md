# Gnuplot

Gnuplot is installed in the image. Because the container is headless, interactive GUI windows are not available by default. Gnuplot writes output to files which open automatically in VS Code.

Add these two lines at the end of every gnuplot script:

```gnuplot
set output
system("code plot.png")
```

---

## A basic script

```gnuplot
# ===========================
# Color scheme
# ===========================
cb_red    = "#D55E00"
cb_blue   = "#0072B2"
cb_green  = "#009E73"

# ===========================
# Terminal and output
# ===========================
set terminal pngcairo enhanced font "Arial,14" size 1600,1200
set output "plot.png"

# ===========================
# Style
# ===========================
set tics nomirror
set mxtics 10
set mytics 10
set xlabel "x"
set ylabel "y"
set key right top

# ===========================
# Plot
# ===========================
plot sin(x) w l lw 3 lc rgb cb_red   title "sin(x)", \
     cos(x) w l lw 3 lc rgb cb_blue  title "cos(x)"

# ===========================
# Open in VS Code
# ===========================
set output
system("code plot.png")
```

Run from the terminal:

```bash
gnuplot script.gp
```

---

## Supported output formats

```gnuplot
set terminal pngcairo       # PNG
set terminal pdfcairo       # PDF — good for papers
set terminal epscairo       # EPS — for LaTeX
set terminal svg            # SVG
```

---

## Shortcomings

**No interactive window.** The `qt`, `wxt`, and `x11` terminals require a display and will fail inside the container. Always set a file-based terminal explicitly — forgetting to do so is the most common mistake.

**No live preview.** The workflow is edit → run → view. For rapid iteration matplotlib in a Jupyter notebook is more convenient.

---

## X11 forwarding (interactive windows)

Only needed for live interactive gnuplot windows. Not required for file output.

### Mac

1. Install [XQuartz](https://www.xquartz.org/)
2. In XQuartz → Preferences → Security → check **Allow connections from network clients**
3. Add to `docker-compose.yml`:

```yaml
environment:
  - DISPLAY=host.docker.internal:0
volumes:
  - /tmp/.X11-unix:/tmp/.X11-unix
```

### Linux

Run once on the host before starting the container:

```bash
xhost +local:docker
```

Add to `docker-compose.yml`:

```yaml
environment:
  - DISPLAY=${DISPLAY}
volumes:
  - /tmp/.X11-unix:/tmp/.X11-unix
```

### Windows

1. Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
2. Launch XLaunch → screen 3 → check **Disable Access Control** → save as `.xlaunch`
3. Add to your WSL2 `~/.bashrc`:

```bash
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
export LIBGL_ALWAYS_INDIRECT=1
```

4. Add to `docker-compose.yml`:

```yaml
environment:
  - DISPLAY=${DISPLAY:-host.docker.internal:0}
```

Once set up, use `set terminal qt` or `set terminal x11` in gnuplot.
