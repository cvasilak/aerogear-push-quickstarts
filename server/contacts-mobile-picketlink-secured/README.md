contacts-mobile-picketlink-secured: Example Application JAX-RS Technologies & Push
=========================================================================================================
Author: Joshua Wilson, Pedro Igor, Erik Jan De Wit, Daniel Bevenius   
Level: Beginner     
Technologies: REST, UnifiedPush Java Client, PicketLink   
Summary: A PicketLink secured example of CRUD REST endpoints.   
Target Product: MP   
Product Versions: EAP 6.1, EAP 6.2, EAP 6.3   
Source: <https://github.com/aerogear/aerogear-push-quickstarts/tree/master/server/contacts-mobile-picketlink-secured>   

What is it?
-----------
This quickstart demonstrates how to create a PicketLink secured Java EE 6 application using JAX-RS,
CDI 1.0, EJB 3.1, JPA 2.0 and Bean Validation 1.0.


*Note: This quickstart uses the following Jackson libraries that are a part of the JBoss EAP private API.*

* *org.codehaus.jackson.jackson-core-asl*
* *org.codehaus.jackson.jackson-mapper-asl*

*A public API will become available in a future EAP release and the private classes will be deprecated, but these classes 
will be maintained and available for the duration of the EAP 6.x release cycle.*

System requirements
-------------------

The application this project produces is designed to be run on Red Hat JBoss Enterprise Application Platform (EAP) 6.1 or 
later with the  Red Hat JBoss Web Framework Kit (WFK) 2.5.

All you need to build this project is Java 6.0 (Java SDK 1.6) or later, Maven 3.0 or later.
 
With the prerequisites out of the way, you're ready to build and deploy.


Configure Maven
---------------

If you have not yet done so, you must [Configure Maven](../../README.md#configure-maven) before testing the quickstarts.

Configure the UnifiedPush Java Sender
---------------

1. Open [quickstarts-config.json](./src/main/resources/META-INF/quickstarts-config.json) configuration file.
2. Adjust the ``` serverUrl ```,  ``` pushApplicationId ``` and the ``` masterSecret ``` parameters according to your UPS configuration.

```
    {"serverUrl": "change_me", "pushApplicationId": "change_me", "masterSecret": "change_me"}
```

You will need to setup an UnifiedPush Server instance to send Push Notifications and communicate with your backend, more information can be found [here](http://aerogear.org/docs/unifiedpush/)   


Start the JBoss EAP Server
-----------------------

1. Open a command line and navigate to the root of the JBoss EAP directory.
2. The following shows the command line to start the server with the default profile:

        For Linux:   EAP_HOME/bin/standalone.sh
        For Windows: EAP_HOME\bin\standalone.bat

   Note: Adding "-b 0.0.0.0" to the above commands will allow external clients (phones, tablets, desktops, etc...) connect through your local network.

   For example

        For Linux:   EAP_HOME/bin/standalone.sh -b 0.0.0.0
        For Windows: EAP_HOME\bin\standalone.bat -b 0.0.0.0


Build and Deploy the Quickstart
-------------------------------

1. Make sure you have started the JBoss EAP server as described above.
2. Open a command line and navigate to the root directory of this quickstart.
3. Type this command to build and deploy the archive:

        mvn clean package jboss-as:deploy

4. This deploys `target/jboss-contacts-mobile-picketlink-secured.war` to the running instance of the server.


Access the application
----------------------

This backend application is used by multiple clients, one of the being the [contacts-mobile-webapp](../../client/contacts-mobile-webapp).
Please follow the ```Build and Deploy the Quickstart``` instructions in [contacts-mobile-webapp](../../client/contacts-mobile-webapp)
which describe how to build, deploy, and access the web application.

FAQ
--------------------

1) Why can't I enter a date in the birthdate field?

  * Chrome has a [bug](https://code.google.com/p/chromium/issues/detail?id=232296) in it
    * Use the arrow keys to change the date: up arrow key, tab to day, up arrow key, tab to year, up arrow key
    * Use the date picker: a large black down arrow between the up/down arrows and the big X on the right side.
  * Firefox, IE, and Safari require strict formatting of YYYY-DD-MM, *Note:* It must be a dash and not a slash


Undeploy the Archive
--------------------

1. Make sure you have started the JBoss EAP server as described above.
2. Open a command line and navigate to the root directory of this quickstart.
3. When you are finished testing, type this command to undeploy the archive:

        mvn jboss-as:undeploy


Run the Arquillian Functional Tests
-----------------------------------

This quickstart provides Arquillian functional tests. They are located under the directory "functional-tests". Functional tests verify that your application behaves correctly from the user's point of view - simulating clicking around the page as a normal user would do.

To run these tests, you must build the main project as described above.

1. Open a command line and navigate to the root directory of this quickstart.
2. Build the quickstart WAR using the following command:

        mvn clean package

3. Navigate to the functional-tests/ directory in this quickstart.
4. If you have a running instance of the JBoss EAP server, as described above, run the remote tests by typing the following command:

        mvn clean verify -Parq-jbossas-remote

5. If you prefer to run the functional tests using managed instance of the JBoss EAP server, meaning the tests will start the server for you, type the following command:

_NOTE: For this to work, Arquillian needs to know the location of the JBoss EAP server. This can be declared through the `JBOSS_HOME` environment variable or the `jbossHome` property in `arquillian.xml`. See [Run the Arquillian Tests](../../README.md#run-the-arquillian-tests) for complete instructions and additional options._

        mvn clean verify -Parq-jbossas-managed



Run the Quickstart in JBoss Developer Studio or Eclipse
-------------------------------------

You can also start the server and deploy the quickstarts from Eclipse using JBoss tools. For more information, 
see [Use JBoss Developer Studio or Eclipse to Run the Quickstarts](../../README.md#use-jboss-developer-studio-or-eclipse-to-run-the-quickstarts)


### Deploying to OpenShift

You can also deploy the application directly to OpenShift, Red Hat's cloud based PaaS offering, follow the 
instructions [here](https://community.jboss.org/wiki/DeployingHTML5ApplicationsToOpenshift)

Run the Arquillian tests
============================

By default, tests are configured to be skipped. The reason is that the sample test is an Arquillian test, which requires 
the use of a container. You can activate this test by selecting one of the container configuration provided  for JBoss.

To run the test in JBoss, first start the container instance. Then, run the test goal with the following profile activated:

    mvn clean test -Parq-jbossas-remote

Import the Project into an IDE
=================================

If you created the project using the Maven archetype wizard in your IDE (Eclipse, NetBeans or IntelliJ IDEA), then there 
is nothing to do. You should already have an IDE project.

Detailed instructions for using Eclipse / JBoss Tools with are provided in the 
[Get Started Developing Applications](http://www.jboss.org/jdf/quickstarts/jboss-as-quickstart/guide/Introduction/ "Get Started Developing Applications").

If you created the project from the command line using archetype:generate, then you need to import the project into your IDE. 
If you are using NetBeans 6.8 or IntelliJ IDEA 9, then all you have to do is open the project as an existing project. 
Both of these IDEs recognize Maven projects natively.

Debug the Application
=============================

If you want to be able to debug into the source code or look at the Javadocs of any library in the project, you can run 
either of the following two commands to pull them into your local repository. The IDE should then detect them.

    mvn dependency:sources
    mvn dependency:resolve -Dclassifier=javadoc
