# -*- coding: utf-8 -*-

from setuptools import setup

setup(
    name='covid19surveyorml',
    version='0.0.1',
    author='covid19surveyor contributers',
    author_email='osoken.devel@outlook.jp',
    license='https://github.com/arakawatomonori/covid19-surveyor/blob/master/LICENSE',
    url='https://github.com/arakawatomonori/covid19-surveyor',
    description='ml package for covid19surveyor',
    long_description='ml package for covid19surveyor',
    packages=['covid19surveyorml'],
    install_requires=[
        'jsonlines', 'mecab-python3', 'numpy', 'scipy', 'torch', 'scikit-learn'
    ],
    entry_points={
        'console_scripts': ["covid19surveyorml=covid19surveyorml:main"]
    }
)
