================================
Note Common Command Use On Linux
================================

Find file inside archives file
------------------------------
.. code-block:: bash

   # find [path to folder contain archive file] -name "*.jar" -exec zipgrep "text searching for" '{}' \;
   find idempiere/.metadata/.plugins/org.eclipse.pde.core/.bundle_pool/plugins/ -name "org.apache.servicemix.bundles.spring*.jar" -exec zipgrep "META-INF/spring.schemas" '{}' \;
   # start from folder idempiere/.metadata/.plugins/org.eclipse.pde.core/.bundle_pool/plugins/
   # recusive all file jar file name start with "org.apache.servicemix.bundles.spring"
   # find file inside jar file contain text "META-INF/spring.schemas"

Compact disk of virtual box
---------------------------
.. code-block:: bash

   # We have window 10 virtual box machine. It use dynamic disk win10.vdi size example 500G
   # Window 10 and data consumer about 100G, so physical file win10.vdi about 100G
   # Now we copy 50G data to win10.vdi, let it resize to about 150G
   # Next we delete that 50G data, but size of win10.vdi keep 150G

   vboxmanage modifyhd win10.vdi  compact

   # command will help we reduce win10.vdi to about 100G
   # this command need a lot space (about 250G) and time to run

Firewall
--------
.. code-block:: bash
   
   sudo firewall-cmd --reload

   sudo firewall-cmd --add-service=http
   sudo firewall-cmd --remove-service=http

Run by root
-----------

.. code-block:: bash

   # when run multi command or use pipeline but exists part need root permission
   # to void permission denied error, we can run group of command by sudo like
   # sudo -SE sh -c "list of command"
   export test="just for test"
   sudo -SE sh -c "echo \"#$test\" >> /etc/environment"