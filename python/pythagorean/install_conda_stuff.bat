# create a new environment with the required packages
conda create  -n "matplotlib_build" python=3.4 numpy python-dateutil pyparsing pytz tornado pyqt cycler tk libpng zlib freetype
activate matplotlib_build
# this package is only available in the conda-forge channel
conda install -c conda-forge msinttypes
# for python 2.7
conda install -c conda-forge functools32

# copy the libs which have "wrong" names
set LIBRARY_LIB=%CONDA_DEFAULT_ENV%\Library\lib
mkdir lib || cmd /c "exit /b 0"
copy %LIBRARY_LIB%\zlibstatic.lib lib\z.lib
copy %LIBRARY_LIB%\libpng_static.lib lib\png.lib

# Make the header files and the rest of the static libs available during the build
# CONDA_DEFAULT_ENV is a env variable which is set to the currently active environment path
set MPLBASEDIRLIST=%CONDA_DEFAULT_ENV%\Library\;.

# build the wheel
python setup.py bdist_wheel