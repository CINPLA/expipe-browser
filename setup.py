# -*- coding: utf-8 -*-
from setuptools import setup
import os

from setuptools import setup, find_packages

long_description = open("README.md").read()

install_requires = []

setup(
    name="expipe-browser",
    packages=find_packages(),
    include_package_data=True,
    entry_points='''
        [console_scripts]
        expipe-browser=expipebrowser.main:main
    '''
)
