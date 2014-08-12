# quickstart-push-android: CRUD Mobile Application showing the AeroGear Push feature on Android

Author: Daniel Passos (dpassos)   
Level: Beginner   
Technologies: Java, Android   
Summary: A Contacts CRUD mobile application with Push notification integration.   
Target Product: Mobile   
Product Versions: EAP 6.1, EAP 6.2, EAP 6.3

## What is it?

This project is an Android mobile front-end to the [Contacts](https://github.com/jboss-developer/jboss-wfk-quickstarts/contacts-mobile-picketlink-secured) server application found in the [quickstarts](https://github.com/jboss-developer/jboss-wfk-quickstarts) of the Red Hat [JBoss Web Framework Kit](http://www.jboss.org/jdf/). All CRUD features are supported, as well as integration with the Push notification mechanism to instantly retrieve a new Contact when it is created on the server. A video demonstrating the application 'in-action' can be found [here](https://vimeo.com/97464515). 

## System requirements

* [Java 7](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
* [Maven 3.1.1](http://maven.apache.org)
* Latest [Android SDK](https://developer.android.com/sdk/index.html) and [Plataform version](http://developer.android.com/tools/revisions/platforms.html)
* Latest [Android Support Library](http://developer.android.com/tools/support-library/index.html) and [Google Play Services](http://developer.android.com/google/play-services/index.html)
* Latest [Maven Android SDK Deployer](https://github.com/mosabua/maven-android-sdk-deployer)


## Pre-requisites

* Both the [Contacts](https://github.com/jboss-developer/jboss-wfk-quickstarts/contacts-mobile-picketlink-secured) and the [AeroGear UnifiedPush Server](https://github.com/aerogear/aerogear-unifiedpush-server) applications up and running. Follow the documentation of each respective project to set them up.
* A valid configured variant on the UPS admin console as well as a valid Google API Key, and a device (Push notifications are not available on simulator). Follow the documentation on the [UPS guide](http://aerogear.org/docs/unifiedpush/aerogear-push-android/) to set them up.


## Build and Deploy the Contacts

### Change Push Configuration

In [Constants.java](./src/org/jboss/aerogear/unifiedpush/quickstart/Constants.java) find and replace ```BASE_URL```,
```UNIFIED_PUSH_URL```, ```VARIANT_ID```, ```SECRET``` and ```GCM_SENDER_ID```. Please refer to the JavaDocs for a
description of each of these constants.

### Application Flow

When you first launch the application, you are required to login. Enter your employee credentials (by default the 'Contacts' backend creates a list of default employees such as '_maria:maria_') and click Login. If the login is successfully, you are presented with a list of existing Contacts residing on the server.

![contacts list home screen](doc/contacts-list.png)

Clicking a Contact reveals the edit screen where you can modify his/her details.

![contact details](doc/contact-details.png)

### Receiving Notifications

To test that you can successfully receive notifications when a new contact is created, open the web interface of the application and try to add a new Contact. Once done, and if the application is successfully configured, immediately you will see the notification popping up on the screen.

![contact details](doc/notification.png)


## FAQ

### Build dependencies locally

Google doesn't ship all the needed libraries to maven central. You need to deploy them locally with [maven-android-sdk-deployer](https://github.com/mosabua/maven-android-sdk-deployer).

#### Checkout maven-android-sdk-deployer
```
git clone git://github.com/mosabua/maven-android-sdk-deployer.git
```

#### Install android platform
```
cd $PWD/maven-android-sdk-deployer/platforms/android-19
mvn install -N --quiet
```

#### Install google-play-services
```
cd $PWD/maven-android-sdk-deployer/extras/google-play-services
mvn  install -N --quiet
```

#### Install compatibility-v4
```
cd $PWD/maven-android-sdk-deployer/extras/compatibility-v4
mvn install -N --quiet
```

#### Install compatibility-v7-appcompat
```
cd $PWD/maven-android-sdk-deployer/extras/compatibility-v7-appcompat
mvn install -N --quiet
```

## Debug the Application

```
mvn clean package android:deploy android:run
```
