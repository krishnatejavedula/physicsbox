# Daily Use

## Starting and stopping

```bash
make start      # start the container in the background
make stop       # stop it
make restart    # restart it
make status     # show container status and image size
```

You do not need to rebuild between sessions. `make start` starts the existing container in seconds.

To open VS Code and attach to the running container:

```bash
code ~/Apps/physicsbox
```

VS Code reconnects automatically.

---

## Terminal

Open a shell inside the container from VS Code with `` Ctrl+` ``. You will land at:

```
(physicsbox) dev@physicsbox:/workspace$
```

The `physicsbox` conda environment is activated automatically.

To open a shell from your host terminal without VS Code:

```bash
make shell
```

To run a single command without entering the container:

```bash
docker exec physicsbox conda run -n physicsbox python myscript.py
docker exec physicsbox gcc mymodel.c -o mymodel $(gsl-config --cflags --libs)
```

---

## JupyterLab

From the terminal inside VS Code:

```bash
notebook
```

Or from your host terminal:

```bash
make notebook
```

Then open [http://localhost:8888](http://localhost:8888) in your browser.
