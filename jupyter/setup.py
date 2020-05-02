# -*- coding: utf-8 -*-

from setuptools import setup

setup(
    name='covid19surveyor-jupyter',
    version='0.0.1',
    author='covid19surveyor contributers',
    author_email='yuiseki@gmail.com',
    license='https://github.com/arakawatomonori/covid19-surveyor/blob/master/LICENSE',
    url='https://github.com/arakawatomonori/covid19-surveyor',
    description='jupyter notebooks for covid19surveyor',
    long_description='jupyter notebooks for covid19surveyor',
    packages=['notebooks'],
    install_requires=[
        'jsonlines', 'mecab-python3', 'numpy', 'scipy', 'torch', 'scikit-learn', 'pandas'
    ],
    entry_points={
        'console_scripts': ["notebooks=notebooks:main"]
    }
)
