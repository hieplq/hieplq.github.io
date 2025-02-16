## Overview

When setting up iDempiere, loading the target platform takes time (the first time it takes about 30 minutes).

It's worse when each time we open the target file and also open Eclipse, it takes time to refresh (sometimes it freezes the IDE).

This is because of Eclipse and the p2 repository. When built by Tycho, it doesn't take as long, but it's still not fast.

[IDEMPIERE-5314](https://idempiere.atlassian.net/browse/IDEMPIERE-5314) and [IDEMPIERE-6108](https://idempiere.atlassian.net/browse/IDEMPIERE-6108) introduce a great way to speed up loading the target by using [Tycho mirror](https://tycho.eclipseprojects.io/doc/main/target-platform-configuration/mirror-target-platform-mojo.html), which clones artifacts to local.

But the mirror target doesn't include sources from some types of p2 repositories [reported here](https://github.com/eclipse-tycho/tycho/discussions/3926#discussioncomment-11027194).

This makes it hard to debug.

## Create Local Target Platform with Source Artifacts

1. Clone the iDempiere source and checkout the branch `release-12` (it's okay for `11` or `master`).
2. [Create a local repository with sources](https://tycho.eclipseprojects.io/doc/main/tycho-p2-repository-plugin/assemble-repository-mojo.html#includeAllSources).

   Open `org.idempiere.p2/pom.xml` and add `<includeAllSources>`.

   <details>
   <summary>Add includeAllSources</summary>

   ```xml
   <plugin>
       <groupId>org.eclipse.tycho</groupId>
       <artifactId>tycho-p2-repository-plugin</artifactId>
       <executions>
           <execution>
               <id>default-assemble-repository</id>
               <goals>
                   <goal>assemble-repository</goal>
               </goals>
               <phase>${assembleRepository}</phase>
           </execution>
           <execution>
               <id>default-archive-repository</id>
               <goals>
                   <goal>archive-repository</goal>
               </goals>
               <phase>${assembleRepository}</phase>
           </execution>
       </executions>
       <configuration>
           <!-- from import package maven can lookup bundle from all repositories 
               declared on target platform, also maven local so default generated site-p2 
               doesn't include that bundle. this configuration changes default behavior -->
           <includeAllDependencies>true</includeAllDependencies>
           <includeAllSources>true</includeAllSources>
           <!-- https://bugs.eclipse.org/bugs/show_bug.cgi?id=512396 -->
           <xzCompress>false</xzCompress>
       </configuration>
   </plugin>

   ```

   </details>
3. Create p2 repository
   Run `mvn verify -Dtycho.buildqualifier.format=yyyyMMdd`
   Now we have a p2 repository at `[idempiere-source]/org.idempiere.p2/target/repository` with the following features:

   * bundle with artifact source
   * include idempiere bundle (org.idempiere, org.adempiere, org.compiere,...)
   * missing bundle for running junit

   Copy and rename `[idempiere-source]/org.idempiere.p2/target/repository` to `~/target/idempiere-dev-12`
   Copy and rename `idempiere-12/org.idempiere.p2.targetplatform/target/target-platform-repository` to `~/target/idempiere-mirror-12`
4. Get list of artifacts

   * Setup update Eclipse with iDempiere source
   * Open `org.idempiere.p2.targetplatform.mirror`
   * Go to the tab content and unselect a bundle
   * Go to the source tab to get the list of bundles
     ![1739685432434](image/mirrorTargetPlatform/1739685432434.png)
   * Process text `<plugin id="bcmail"/>` to get the name (bcmail) only
   * Some bundles have multiple versions and need special processing:

     * com.sun.xml.fastinfoset.FastInfoset
     * org.apache.ws.xmlschema.core

     ```
     com.sun.xml.fastinfoset.FastInfoset" version="2.0.0
     com.sun.xml.fastinfoset.FastInfoset" version="1.2.18.v202109010034
     ```

     to
     ```
     com.sun.xml.fastinfoset.FastInfoset [2.0.0,2.0.0]
     com.sun.xml.fastinfoset.FastInfoset [1.2.18,1.2.18]
     // com.sun.xml.fastinfoset.FastInfoset" version="2.0.0
     // com.sun.xml.fastinfoset.FastInfoset" version="1.2.18.v202109010034
     ```
   * Comment the list of the following bundles because they aren't inside the iDempiere product, so they aren't output to the repository when running `target-platform-repository`:

     ```
     biz.aQute.bndlib
     com.sun.xml.bind.external.rngom
     org.apache.cxf.cxf-rt-transports-local
     org.apache.santuario.xmlsec
     org.eclipse.equinox.launcher.cocoa.macosx
     org.eclipse.equinox.launcher.cocoa.macosx.aarch64
     org.eclipse.equinox.launcher.gtk.linux.aarch64
     org.eclipse.equinox.launcher.gtk.linux.ppc64le
     org.eclipse.jdt.junit5.runtime
     org.osgi.service.obr
     wrapped.com.beust.jcommander
     wrapped.com.github.virtuald.curvesapi
     wrapped.com.google.j2objc.j2objc-annotations
     wrapped.de.rototor.pdfbox.graphics2d
     wrapped.org.apache.activemq.activemq-broker
     wrapped.org.jboss.spec.javax.rmi.jboss-rmi-api_1.0_spec
     wrapped.org.mortbay.jetty.quiche.jetty-quiche-native
     wrapped.xml-resolver.xml-resolver
     ```
   * At the moment, there are the following errors, so comment out that bundle (with error version) as well:

     ```
     No installable unit with ID 'com.sun.xml.fastinfoset.FastInfoset' can be found with range constraint '[1.2.18,1.2.18]'
     No installable unit with ID 'org.apache.ws.xmlschema.core' can be found with range constraint '[2.2.5,2.2.5]'
     ```
   * Manually add the bundle unselected above
   * Create a new project called `org.idempiere.target` inside `~/target` (becomes `~/target/org.idempiere.target`)
   * Inside `org.idempiere.target`, create the file `org.idempiere.p2.targetplatform.12.dev.tpd` (can duplicate `org.idempiere.p2.targetplatform.tpd`)
   * Inside `org.idempiere.target`, create the file `org.idempiere.p2.targetplatform.12.mirror.target` (can duplicate `org.idempiere.p2.targetplatform.mirror.target`)
5. Edit the file `org.idempiere.target/org.idempiere.target/org.idempiere.p2.targetplatform.12.dev.tpd`

   * Delete all locations, keep only one
   * Modify the location to `location all "file:/home/[user]/target/idempiere-dev-12" {`
   * Append the list of artifacts from step 4 to the location
   * Right-click the file `org.idempiere.p2.targetplatform.12.dev.tpd` and choose "create target definition file" to generate the file `org.idempiere.p2.targetplatform.12.dev.target`
     ![1739689307118](image/mirrorTargetPlatform/1739689307118.png)
6. Edit the file `org.idempiere.target/org.idempiere.p2.targetplatform.12.mirror.target`

   * Change the value of the path from `${project_loc:org.idempiere.p2.targetplatform}/target/target-platform-repository` to `/home/[user]/target/idempiere-mirror-12`

## Result

From now on, each time we set up the iDempiere workspace, just import the project `org.idempiere.target` to Eclipse and activate the target according to the purpose:

* For debugging, just open and activate `org.idempiere.p2.targetplatform.12.dev.target`
* For running unit tests, just open and activate `org.idempiere.p2.targetplatform.12.mirror.target`

**I keep my version [here](https://github.com/hieplq/idempiere.target)**

## Note

Why is the list of bundles in `~/target/idempiere-dev-12` different from `~/target/idempiere-mirror-12`?

Because `~/target/idempiere-mirror-12` is based on the target file, but `~/target/idempiere-dev-12` is based on the iDempiere product.
