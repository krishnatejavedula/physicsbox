# Environment

## Build variants

PhysicsBox has two build variants:

| Variant | Contents | Approx size |
|---|---|---|
| `lean` (default) | numpy, scipy, matplotlib, jupyterlab, ipykernel, ipython | ~1.5 GB |
| `full` | Everything in lean + pandas, sympy, seaborn, statsmodels, uncertainties, astropy, h5py, plotly, scikit-learn, numba, dask, pyarrow, streamlit, s3fs, brotli, wordcloud | ~4.5 GB |

```bash
make install           # lean — recommended for students
make install-full      # full — for your own machine
```

---

## Managing packages

### Python packages — temporary

Works immediately but lost on rebuild:

```bash
pip install lmfit
conda install astroml -c conda-forge
```

### Python packages — permanent

Add the package to `environment.lean.yml` or `environment.full.yml` then rebuild:

```bash
make rebuild
```

### System libraries — temporary

```bash
sudo apt-get install libgoogle-perftools-dev
```

Lost on rebuild. For anything you use regularly, make it permanent.

### System libraries — permanent

Add the package to the `apt-get install` block in the `Dockerfile`:

```dockerfile
    RUN apt-get install -y --no-install-recommends \
            ...
            libgoogle-perftools-dev \ # ← add here
```

Then rebuild:

```bash
make rebuild
```
---

## Conda environments

The default environment is `physicsbox` and is activated automatically on every shell.

### Create a new environment

```bash
conda create -n myenv python=3.11 numpy scipy -c conda-forge
conda activate myenv
```

### List all environments

```bash
conda env list
```

### Switch environments

```bash
conda activate myenv
conda activate physicsbox    # switch back to default
```

### Install packages into a specific environment

```bash
conda install -n myenv lmfit -c conda-forge
```

### Remove an environment

```bash
conda deactivate
conda env remove -n myenv
```

### Make a new environment persistent
Additional environments created at runtime are lost on rebuild. To make one permanent, add a second `mamba create` block in the `Dockerfile` after the existing one:

```dockerfile
RUN mamba create -n myenv python=3.11 \
        lmfit \
        corner \
        -c conda-forge && \
    mamba clean -a -y
```

Then rebuild:

```bash
make rebuild
```