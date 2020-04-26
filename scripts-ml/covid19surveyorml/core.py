# -*- coding: utf-8 -*-

from abc import ABCMeta, abstractmethod
import pickle
import io

import torch
from torch import nn
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing import MultiLabelBinarizer

from . common import preprocess, calc_score

class BasePredictor(metaclass=ABCMeta):
    def __init__(self):
        pass

    @abstractmethod
    def train(self, x, y):
        pass

    @abstractmethod
    def eval(self, x):
        pass


class TorchMLP(BasePredictor):
    def __init__(self, tensorizer, network, label_encoder, device='cpu'):
        super(TorchMLP, self).__init__()
        self.device = device
        self.tensorizer = tensorizer
        self.network = network
        self.label_encoder = label_encoder

    @classmethod
    def create_network(cls, input_dim, output_dim):
        return nn.Sequential(
            nn.Linear(input_dim, 300),
            nn.ReLU(),
            nn.Linear(300, output_dim),
            nn.Sigmoid()
        )

    @classmethod
    def train(cls, x, y, device=None, verbose=False):
        device = device if device is not None else torch.device(
            'cuda: 0' if torch.cuda.is_available() else 'cpu'
        )
        text_data = [preprocess(d) for d in x]
        x_train, x_test, y_train, y_test = train_test_split(
            text_data, y, test_size=0.2
        )
        tensorizer = TfidfVectorizer(min_df=2, token_pattern=r'(?u)\s\w+\s')
        x_train = tensorizer.fit_transform(
            x_train
        ).astype(np.float32).toarray()
        x_test = tensorizer.transform(x_test).astype(np.float32).toarray()

        labelencoder = MultiLabelBinarizer()
        y_train = labelencoder.fit_transform([[d] for d in y_train])
        y_test = labelencoder.transform([[d] for d in y_test])
        n_classes = len(labelencoder.classes_)

        x_train_t = torch.Tensor(x_train).to(device)
        y_train_t = torch.Tensor(y_train).float().to(device)
        x_test_t = torch.Tensor(x_test).to(device)
        y_test_t = torch.Tensor(y_test).float().to(device)

        m = cls.create_network(len(tensorizer.vocabulary_), n_classes)
        m.to(device)

        loss = nn.BCELoss()
        optimizer = torch.optim.Adam(m.parameters())

        best_loss = None
        best_model = None
        best_pred = None

        for epoch in range(10000):
            m.train()
            optimizer.zero_grad()
            v = m(x_train_t)
            l = loss(v, y_train_t)
            l.backward()
            optimizer.step()
            m.eval()
            with torch.no_grad():
                test_pred = m(x_test_t)
                test_loss = loss(test_pred, y_test_t).item()
                if best_loss is None or best_loss > test_loss:
                    best_loss = test_loss
                    buf = io.BytesIO()
                    m.to('cpu')
                    torch.save(m, buf)
                    m.to(device)
                    best_model = buf.getvalue()
                    best_pred = test_pred.to('cpu').detach().numpy()
                if verbose:
                    print(
                        'epoch {:04}: '.format(epoch),
                        'loss', l.item(), 'testloss', test_loss,
                        'best', best_loss, 'ratio', (test_loss / best_loss)
                    )
                if 1.03 < (test_loss / best_loss):
                    break
        return {
            'model': cls(
                tensorizer,
                torch.load(io.BytesIO(best_model)),
                labelencoder,
                device
            ),
            'scores': {
                k: calc_score(y_test[:, i], best_pred[:, i])
                for i, k in enumerate(labelencoder.classes_)
            }
        }

    def eval(self, x):
        if isinstance(x, list):
            t = [preprocess(d) for d in x]
        else:
            t = [preprocess(x)]
        x = self.tensorizer.transform(t).astype(np.float32).toarray()
        self.network.eval()
        p = self.network(torch.Tensor(x).to(self.device)).to('cpu')\
            .detach().numpy().tolist()
        return [{
            k: v for k, v in zip(self.label_encoder.classes_, pp)
        } for pp in p]

    def __getstate__(self):
        tensorizer_buf = io.BytesIO()
        pickle.dump(self.tensorizer, tensorizer_buf)
        network_buf = io.BytesIO()
        self.network.to('cpu')
        torch.save(self.network, network_buf)
        self.network.to(self.device)
        label_encoder_buf = io.BytesIO()
        pickle.dump(self.label_encoder, label_encoder_buf)
        return {
            'tensorizer': tensorizer_buf.getvalue(),
            'network': network_buf.getvalue(),
            'label_encoder': label_encoder_buf.getvalue()
        }

    def __setstate__(self, state):
        device = torch.device(
            'cuda: 0' if torch.cuda.is_available() else 'cpu'
        )
        network = torch.load(io.BytesIO(state['network']))
        network.to(device)
        self.tensorizer = pickle.load(io.BytesIO(state['tensorizer']))
        self.network = network
        self.label_encoder = pickle.load(io.BytesIO(state['label_encoder']))
        self.device = device
