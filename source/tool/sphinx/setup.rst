=================
Setup Environment
=================
| This one is my practice on setup environment to write by document by use:
|   `Linux Mint 19.3 Tricia <https://www.linuxmint.com/download.php>`_ 
|   `ReStructuredText <https://docutils.sourceforge.io/rst.html>`_ as markup syntax
|   `Sphinx <https://www.sphinx-doc.org/>`_ as engine build
|   `Visual Code <https://code.visualstudio.com/download>`_ as compose editor and project manage
|   `Vscode-restructuredtext extension <https://github.com/vscode-restructuredtext/vscode-restructuredtext>`_ to support intelliSense and live preview
|   `Python Virtual Environment <https://docs.python.org/3/tutorial/venv.html>`_ for manage python environment
|   `Readthedocs <docs.readthedocs.io>`_ for online build and hosting document

| First I follow guideline of `Vscode-restructuredtext extension <https://docs.restructuredtext.net/articles/prerequisites.html>`_ but don't success
| I get a lot issue relate manage package of python
| I end up by use python virtual environment so I easy reset python to clean and try util success

Prerequisites
-------------
| Visual Code is installed
| Python 3.x is installed
| git is installed

Command
-------
.. raw:: html

   <details>
   <summary><a>Raw command list only command start util success</a></summary>

.. code-block:: bash
   :linenos:

   sudo apt-get install python3 python3-venv

   export PYTHON_SPHINX_DIR=/mnt/data/1Dev/program/pythonSphinx
   mkdir -p $PYTHON_SPHINX_DIR
   python3 -m venv $PYTHON_SPHINX_DIR
   source $PYTHON_SPHINX_DIR/bin/activate
   pip install -q -U sphinx sphinx-autobuild sphinx_rtd_theme rstcheck pylint

   code --install-extension lextudio.restructuredtext
   code --install-extension ms-python.python

   export docRoot=/mnt/data/1Dev/project/hieplq/document
   export docPro=hieplq.github.io
   mkdir -p $docRoot/$docPro
   
   cd $docRoot/$docPro
   source $PYTHON_SPHINX_DIR/bin/activate

   sphinx-quickstart 
   Y
   Just document
   Hieplq
   1.0.0
   en

   cd $docRoot/$docPro
   git init
   touch $docRoot/$docPro/.gitignore
   cat <<EOT >> $docRoot/$docPro/.gitignore
   /build/
   EOT
   git add -A
   git commit --cleanup=whitespace -a -m "init with sphinx-quickstart"

   sed -i -r "s|(^# import sys.*)|\1\nimport sphinx_rtd_theme|g" $docRoot/$docPro/source/conf.py
   sed -i -r "s|(^extensions = \[.*)|\1\n    'sphinx_rtd_theme'|g" $docRoot/$docPro/source/conf.py
   sed -i -r "s|(^html_theme = .*)|\#\1\nhtml_theme = \"sphinx_rtd_theme\"|g" $docRoot/$docPro/source/conf.py

   git add -A
   git commit --cleanup=whitespace -a -m "setup to use theme sphinx_rtd_theme provide by readthedocs"

   cd $docRoot/$docPro/source
   sphinx-build -a -E -v -b html -j auto . "../build/html" -c .

   mkdir -p $docRoot/$docPro/.vscode
   touch $docRoot/$docPro/.vscode/settings.json

   cat <<EOT >> $docRoot/$docPro/.vscode/settings.json
   {
      "python.pythonPath"                       : "\${env:PYTHON_SPHINX_DIR}/bin/python",        // use enviroment variable PYTHON_SPHINX_DIR for portable
      // https://docs.restructuredtext.net/articles/configuration.html
      "restructuredtext.sphinxBuildPath"        : "\${env:PYTHON_SPHINX_DIR}/bin/sphinx-build",  // isn't required when we already set python.pythonPath
      "restructuredtext.linter.executablePath"  : "\${env:PYTHON_SPHINX_DIR}/bin/rstcheck",      // isn't required when we already set python.pythonPath
      "restructuredtext.linter.run"             : "onSave",                               // correct value onType, onSave, and off
      "restructuredtext.builtDocumentationPath" : "\${workspaceRoot}/build/html",         // output sync with build by command line, make or sphinx-build
      "restructuredtext.confPath"               : "\${workspaceFolder}/source",           // root source folder, contain conf.py
      "restructuredtext.updateOnTextChanged"    : "true",
      "restructuredtext.updateDelay"            : 1000,
      "restructuredtext.languageServer.disabled": false                                  // support IntelliSense, default is disable because still experimental
   }
   EOT

   cd $docRoot/$docPro
   git add -A
   git commit --cleanup=whitespace -a -m "setup virtual code"

   touch $docRoot/$docPro/readthedocs.yml

   cat <<"EOT" >> $docRoot/$docPro/readthedocs.yml
   build:
     image: stable

   version: 2

   sphinx:
     builder: html
     configuration: source/conf.py
     fail_on_warning: false

   formats: all

   python:
     version: 3.7
     install:
       - requirements: requirements.txt
   EOT

   touch $docRoot/$docPro/requirements.txt
   cat <<"EOT" >> $docRoot/$docPro/requirements.txt
   sphinx==2.4.4
   EOT

   git add -A
   git commit --cleanup=whitespace -a -m "customize build of readthedocs https://docs.readthedocs.io/en/stable/config-file/index.html"

   code --unity-launch --new-window --folder-uri $docRoot/$docPro --file-uri $docRoot/$docPro/source/conf.py $docRoot/$docPro/source/index.rst

.. raw:: html

   </details>

.. raw:: html

   <details>
   <summary><a>Command step by step with explain for debug and understand</a></summary>

.. code-block:: bash
   :linenos:
   
   #### setup python environment https://docs.python.org/3.8/library/venv.html#module-venv
   sudo apt-get install python3 python3-venv
   export PYTHON_SPHINX_DIR=/mnt/data/1Dev/program/pythonSphinx
   mkdir -p $PYTHON_SPHINX_DIR
   python3 -m venv $PYTHON_SPHINX_DIR
   # active python virtual environment
   source $PYTHON_SPHINX_DIR/bin/activate

   #### install sphinx and relate to current active python
   pip install -U sphinx
   sphinx-build --version

   #### create sphinx project
   export docRoot=/mnt/data/1Dev/project/hieplq/document
   export docPro=hieplq.github.io
   mkdir -p $docRoot/$docPro
   cd $docRoot/$docPro

   sphinx-quickstart 
   Y
   Document for everything meet on dev life
   Hieplq
   1.0.0
   en

   ## create git repository and commit project init from template
   cd $docRoot/$docPro
   git init
   touch $docRoot/$docPro/.gitignore

   cat <<EOT >> $docRoot/$docPro/.gitignore
   /build/
   EOT

   git add -A
   git commit --cleanup=whitespace -a -m "init with sphinx-quickstart"

   #### build to see no problem with setup
   # use make file
   cd $docRoot/$docPro
   make html

   # use sphinx command
   # current dir is folder contain index.rst (master doc)
   cd $docRoot/$docPro/source
   sphinx-build -a -E -v -b html -j auto $docRoot/$docPro/source $docRoot/$docPro/build/html -c $docRoot/$docPro/source

   #### Setup Visual Code
   # install extension for VS Code
   code --install-extension lextudio.restructuredtext
   code --install-extension ms-python.python

   # install python extension to current active python https://docs.restructuredtext.net/articles/prerequisites.html
   pip install -U sphinx-autobuild rstcheck pylint

   # setup visual code workspace setting for current project
   mkdir -p $docRoot/$docPro/.vscode
   touch $docRoot/$docPro/.vscode/settings.json

   cat <<EOT >> $docRoot/$docPro/.vscode/settings.json
   {
      "python.pythonPath"                       : "\${env:PYTHON_SPHINX_DIR}/bin/python",        // use enviroment variable PYTHON_SPHINX_DIR for portable
      // https://docs.restructuredtext.net/articles/configuration.html
      "restructuredtext.sphinxBuildPath"        : "\${env:PYTHON_SPHINX_DIR}/bin/sphinx-build",  // isn't required when we already set python.pythonPath
      "restructuredtext.linter.executablePath"  : "\${env:PYTHON_SPHINX_DIR}/bin/rstcheck",      // isn't required when we already set python.pythonPath
      "restructuredtext.linter.run"             : "onSave",                               // correct value onType, onSave, and off
      "restructuredtext.builtDocumentationPath" : "\${workspaceRoot}/build/html",         // output sync with build by command line, make or sphinx-build
      "restructuredtext.confPath"               : "\${workspaceFolder}/source",           // root source folder, contain conf.py
      "restructuredtext.updateOnTextChanged"    : "true",
      "restructuredtext.updateDelay"            : 1000,
      "restructuredtext.languageServer.disabled": false                                  // support IntelliSense, default is disable because still experimental
   }
   EOT

   # launch visual code, and load project
   code --unity-launch --new-window --folder-uri $docRoot/$docPro --file-uri $docRoot/$docPro/source/conf.py

   # commit change to git
   cd $docRoot/$docPro
   git add -A
   git commit --cleanup=whitespace -a -m "setup virtual code"

   #### setup to build with readthedocs
   ## readthedocs at moment use sphinx < 2 by default
   ## so need to customize it to build by sphinx 2.4.4

   touch $docRoot/$docPro/readthedocs.yml

   cat <<"EOT" >> $docRoot/$docPro/readthedocs.yml
   build:
     image: stable

   version: 2

   sphinx:
     builder: html
     configuration: source/conf.py
     fail_on_warning: false

   formats: all

   python:
     version: 3.7
     install:
       - requirements: requirements.txt
   EOT

   touch $docRoot/$docPro/requirements.txt
   
   cat <<"EOT" >> $docRoot/$docPro/requirements.txt
   sphinx==2.4.4
   EOT

   # commit change to git
   git add -A
   git commit --cleanup=whitespace -a -m "customize build of readthedocs https://docs.readthedocs.io/en/stable/config-file/index.html"

.. raw:: html

   </details>

Visual code in action
---------------------

| After latest command, we has a visual code window like bellow
.. figure:: /_static/image/sphinx/visualcodeinit.png
   :scale: 30 %

   Visual code ready for preview and intelliSense 

| To see preview and intelliSense effect
.. figure:: /_static/image/sphinx/visualcodeeffect.png
   :scale: 30 %

   Visual code preview and intelliSense in effect

| `More keyword <https://docs.restructuredtext.net/articles/snippets.html>`_ 

Common issue
------------

| At the moment we close visual code and reopen from other terminal or from linux menu or by click icon on panel or icon on desktop it lost preview and intelliSense ability
.. figure:: /_static/image/sphinx/visualcodeopenwithoutenv.png
   :scale: 30 %

   Visual code without correct python enviroment

| Reason of above error by project setting depend on enviroment variable PYTHON_SPHINX_DIR
.. figure:: /_static/image/sphinx/visualcodedependonpythonsphinxdir.png
   :scale: 30 %

   Visual code reason for lost preview and intelliSense ability

| That dependency on wish it help portable when clone project on new PC
| I like this method. in case you dislike you can choose bellow method

Setup python path
-----------------
1. Use absolute path per project

   - on .vscode/settings.json replace env:PYTHON_SPHINX_DIR by absolute path
   .. note:: by this method when some guys working on same project, need to maintain .vscode/settings.json on local to avoid conflict

2. Setting per visual code per user

   - on .vscode/settings.json delete setting of "python.pythonPath", "restructuredtext.sphinxBuildPath", "restructuredtext.linter.executablePath"
   - on visual code open command palette by type Ctrl+Shift+P, patse "Preferences: Open User Settings" then enter to open setting panel
   - search for python.pythonPath and change its value
   .. note:: by this method, every project use same setting per user
   
3. Setup per project and use environment variable to portable (my prefer method)

   - setting python.pythonPath on .vscode/settings.json
   - use enviroment variable to define path like PYTHON_SPHINX_DIR
   .. note:: so incase we need separate enviroment for many project, just define more python virtual enviroment and use each enviroment variable per project
   - permanente set enviroment variable to system wide

   .. code-block:: bash
      :linenos:
      :caption: Permanente system wide enviroment variable

      sudo su
      cat <<EOT >> /etc/environment
      PYTHON_SPHINX_DIR=/mnt/data/1Dev/program/pythonSphinx
      EOT
      exit

   .. warning:: logout and relogin to linux for take effect
   
Reference
---------
| `Restructuredtext extension for visual code <https://docs.restructuredtext.net/index.html>`_ 
| `Use enviroment variable on visual code setting <https://code.visualstudio.com/docs/editor/variables-reference>`_ 
| `Setting python on vitual code <https://code.visualstudio.com/docs/python/environments>`_ 
| `Explain about workspace on virtual code <https://stackoverflow.com/a/57134632>`_ 
| `ReStructuredText reference <https://docutils.sourceforge.io/docs/ref/rst/directives.html>`_ 