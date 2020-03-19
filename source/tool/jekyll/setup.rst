============================
Setup Environment For Jekyll
============================

.. code-block:: bash
   :linenos:

   # globle install
   sudo apt-get install ruby-full ruby-all-dev build-essential zlib1g-dev
   sudo gem update --system
   gem install bundle

   # create folder content of document project
   export DOC_DIR=
   mkdir $DOC_DIR
   cd $DOC_DIR

   # init virtual enviroment of ruby
   bundle init
   bundle config set path 'vendor/bundle'

   # install jekyll to create document project from template
   bundle add jekyll -v 3.8.5
   bundle exec jekyll new --force --skip-bundle .

   # use github-pages to manage dependency for project
   sed -i -E 's|^gem "jekyll", "~> 3.8.5"|#gem "jekyll", "~> 3.8.5"|g' $DOC_DIR/Gemfile
   sed -i -E 's|^# gem "github-pages", group: :jekyll_plugins|gem "github-pages", group: :jekyll_plugins|g' $DOC_DIR/Gemfile

   ## github has README.md to document repository, use it also for index of document
   # support readme.md and use jekyll-theme-minimal theme
   sed -i 's|^plugins:|plugins:\n  - jekyll-readme-index|g' $DOC_DIR/_config.yml

   # by use README.md we delete index.md
   rm $DOC_DIR/index.md	

   # user default them of github page jekyll-theme-minimal
   sed -i 's|^theme: minima|theme: jekyll-theme-minimal|g' $DOC_DIR/_config.yml

   # install dependency bundle for project
   bundle install --clean
   bundle update github-pages

   # to build github page, project must be git repository
   git init
   # to build github page, it need to link repository, we can bind with a fake or real. here use fake for demo
   git remote add origin git@github.com:hieplq/test.doc.git
   
   # ignore virtual environment folder
   touch $DOC_DIR/.gitignore
   cat <<EOT >> $DOC_DIR/.gitignore
   /_site/
   /.sass-cache/
   /.jekyll-cache/
   /.jekyll-metadata/
   /vendor/
   /.bundle/
   EOT

   # build and host on local to test
   bundle exec jekyll serveebookShare


Referrence
----------
| `Dependency of github page environment <https://pages.github.com/versions/>`_
| `Install Jekyl on ubuntu <https://jekyllrb.com/docs/installation/ubuntu/>`_ 
| `Common terminology on Jekyl world <https://jekyllrb.com/docs/ruby-101/>`_ 
| `Github-pages <https://help.github.com/en/github/working-with-github-pages/creating-a-github-pages-site-with-jekyll>`_ 