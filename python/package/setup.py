from setuptools import setup, find_packages
from setuptools.dist import Distribution
import sys
import sysconfig

if sys.version_info < (3, 0):
    sys.exit('Sorry, Python < 3.0 is not supported')


class BinaryDistribution(Distribution):
    """Distribution which always forces a binary package with platform name"""

    def has_ext_modules(foo):
        return True


name = 'pymylib'
setup(
    name=name,
    version='0.0.1',
    long_description="Only to be used to install package for your current build tree",
    packages=find_packages(),
    include_package_data=True,
    package_data={
        '': [f'lib/{name}{sysconfig.get_config_var("EXT_SUFFIX")}']
    },
    # install_requires=['pandas', 'numpy'],
    distclass=BinaryDistribution
)
