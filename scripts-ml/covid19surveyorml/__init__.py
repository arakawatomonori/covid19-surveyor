# -*- coding: utf-8 -*-

import os
from argparse import ArgumentParser
import sys
import pickle
import json

from . io import read_csv
from . core import TorchMLP


def main():
    parser = ArgumentParser()
    parser.add_argument('-v', action='store_true')
    subparsers = parser.add_subparsers(dest='proc')
    train_parser = subparsers.add_parser('train')
    train_parser.add_argument(
        'input', nargs='+'
    )
    train_parser.add_argument(
        'output'
    )
    eval_parser = subparsers.add_parser('eval')
    eval_parser.add_argument(
        'model'
    )
    eval_parser.add_argument(
        '--input_file'
    )
    args = parser.parse_args()

    if args.proc == 'train':
        data = []
        for fn in args.input:
            with open(fn, 'r') as fin:
                data += list(read_csv(fin))
        train_result = TorchMLP.train(
            [d[0] for d in data], [d[1] for d in data],
            verbose=args.v
        )
        if args.v:
            print(train_result['scores'])
        with open(args.output, 'wb') as fout:
            pickle.dump(train_result['model'], fout)
    elif args.proc == 'eval':
        with open(args.model, 'rb') as fin:
            m = pickle.load(fin)
        texts = []
        if args.input_file is None:
            texts = list(sys.stdin)
        else:
            with open(args.input_file, 'r') as fin:
                texts = list(fin)
        res = m.eval(texts)
        for d in res:
            json.dump(d, sys.stdout)
            sys.stdout.write('\n')
