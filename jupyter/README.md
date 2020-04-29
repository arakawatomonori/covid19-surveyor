
# Build
```
docker build -t covid19surveyor-jupyter .
```

# Run
```
docker run --rm -p 8888:8888 --name jupyter -v $(pwd)/notebooks:/home/jovyan/work -v $(pwd)/../data \
  covid19surveyor-jupyter start-notebook.sh --NotebookApp.password='sha1:4ebf46c17ed6:fd0fad635308240b61af2c23b70b921def2073ef'
```