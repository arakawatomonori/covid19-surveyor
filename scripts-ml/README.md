# ML Docker files

## build

このファイル（`README.md`）のある場所で、以下のコマンドを実行（要 10 分〜）

```
docker build -t covid19surveyorml .
```

## コマンドの概要とヘルプの表示

```
docker run --rm covid19surveyorml              # コマンド全体のヘルプの表示
docker run --rm covid19surveyorml --help       # コマンド全体のヘルプの表示
docker run --rm covid19surveyorml train --help # 訓練用コマンドのヘルプの表示
docker run --rm covid19surveyorml eval --help  # 評価用コマンドのヘルプの表示
```

## 学習の実行

```
docker run --rm -v /path/to/data:/data covid19surveyorml:latest -v train \
  /data/auto-ml-vote.csv \
  /data/auto-ml-bool.csv \
  /data/model.pkl
```

最後の引数以外は2カラムの学習データとして解釈する。最後の引数はモデルの保存ファイルである

### 実行例

（`$` から始まる行は実行コマンド）

```
$ docker run --rm -v $(pwd)/../data:/data covid19surveyorml:latest -v train /data/auto-ml-vote.csv /data/model.pkl
epoch 0000:  loss 0.7089688181877136 testloss 0.7021684050559998 best 0.7021684050559998 ratio 1.0
epoch 0001:  loss 0.7019336223602295 testloss 0.6949419379234314 best 0.6949419379234314 ratio 1.0
...
epoch 0116:  loss 0.08484300971031189 testloss 0.1915891319513321 best 0.18608225882053375 ratio 1.0295937568992508
epoch 0117:  loss 0.08366706967353821 testloss 0.19195358455181122 best 0.18608225882053375 ratio 1.031552313307525
{'covid19_help': {'prAuc': 0.5108956074874671, 'accuracy': 0.8977853492333902, 'precision': 0.631578947368421, 'recall': 0.34285714285714286, 'f1Score': 0.4444444444444445}, 'not_covid19_help': {'prAuc': 0.9770447409595431, 'accuracy': 0.8960817717206133, 'precision': 0.9171270718232044, 'recall': 0.9688715953307393, 'f1Score': 0.9422894985808893}, 'unknown': {'prAuc': 0.011567947707088778, 'accuracy': 0.9948892674616695, 'precision': 0.0, 'recall': 0.0, 'f1Score': 0.0}}
```

`-v` オプションで、最後の行に精度が出る。

## 評価の実行

```
docker run --rm -v /path/to/data:/data covid19surveyorml:latest eval \
  /data/model.pkl \
  --input_file /data/data_to_evaluate.csv
```

`--input_file` で指定しているファイルは、一行に一つのテキストが入ったファイルである。
出力は、モデルの評価結果を一行ずつ JSON 形式。

### 実行例

（`$` から始まる行は実行コマンド）

```
$ docker run --rm -v $(pwd)/../data:/data covid19surveyorml:latest eval /data/model.pkl --input_file /data/auto-ml-bool.csv
{"covid19_help": 0.2266090214252472, "not_covid19_help": 0.7497193217277527, "unknown": 0.0017348355613648891}
{"covid19_help": 0.17880365252494812, "not_covid19_help": 0.800228476524353, "unknown": 0.002171602565795183}
{"covid19_help": 0.11250874400138855, "not_covid19_help": 0.881363570690155, "unknown": 0.018047135323286057}
...
{"covid19_help": 0.26598626375198364, "not_covid19_help": 0.7078602313995361, "unknown": 0.018859731033444405}
```
