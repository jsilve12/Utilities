from setuptools import find_packages, setup

setup(
    name='utilities',
    packages=find_packages(include=['Analysis', 'Common', 'ETL', 'Web-Py']),
    version='1.0.0',
    description='Utilities, stored for re-use',
    author='Jonathan Silverstein',
    license='Not Yours :)',
    install_requires=[]

)
