# el-CICD Operating Manual

## Preamble

This document is part of the el-CICD Project, a complete CICD system for the OKD Container Platform.

Copyright (C) 2020 Evan "Hippy" Slatis  
email: hippyod -at- yahoo -dot- com

**===================================**

**Red Hat® OpenShift® Platform is a trademark of Red Hat, Inc., and supported and owned by Red Hat, Inc.**

**el-CICD IS NEITHER SUPPORTED OR AFFILIATED IN ANY WAY WITH RED HAT, INC., OR ANY OF ITS PROJECTS.**

**===================================**

## License

el-CICD is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE**.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to

```text
    The Free Software Foundation, Inc.
    51 Franklin Street
    Fifth Floor
    Boston, MA
        02110-1301
```

This document is licensed under the [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/legalcode). To view a copy of this license, visit

http://creativecommons.org/licenses/by/4.0/

or send a letter to

```text
  Creative Commons
  PO Box 1866
  Mountain View, CA
      94042
```

# TABLE OF CONTENTS

* [el-CICD Operating Manual](#el-cicd-operating-manual)
  * [Preamble](#preamble)
  * [License](#license)
* [TABLE OF CONTENTS](#table-of-contents)
* [Overview](#overview)
  * [Fundamentals](#fundamentals)
  * [Assumptions](#assumptions)
* [The el-CICD Repositories](#the-el-cicd-repositories)
  * [el-CICD Repository](#el-cicd-repository)
  * [el-CICD-config Repository](#el-cicd-config-repository)
  * [el-CICD-docs Repository](#el-cicd-docs-repository)
* [Configuration](#configuration)
  * [System Files](#system-files)
    * [Location](#location)
    * [Composing](#composing)
      * [Bootstrap and Secrets](#bootstrap-and-secrets)
      * [System](#system)
      * [el-cicd-meta-info](#el-cicd-meta-info)
    * [Contents](#contents)
      * [Basic Information](#basic-information)
      * [Cluster Information](#cluster-information)
      * [Git Repository Information](#git-repository-information)
      * [SDLC](#sdlc)
        * [Lifecycle Definition](#lifecycle-definition)
        * [Image Repositories](#image-repositories)
    * [Jenkins Configuration](#jenkins-configuration)
      * [Dockerfiles](#dockerfiles)
      * [Jenkins Plugins](#jenkins-plugins)
    * [User-defined](#user-defined)
  * [Managed OKD Resources](#managed-okd-resources)
    * [Templates](#templates)
    * [ResourceQuotas](#resourcequotas)
  * [Project Definition File](#project-definition-file)
    * [OKD RBAC Groups](#okd-rbac-groups)
    * [Git Project information](#git-project-information)
    * [Microservices](#microservices)
    * [Enabled Test Environments](#enabled-test-environments)
    * [Sandbox Environments](#sandbox-environments)
  * [Code Base Framework](#code-base-framework)
    * [Jenkins Agents](#jenkins-agents)
    * [Builder Steps](#builder-steps)
      * [Code Base Folders](#code-base-folders)
      * [Build Scripts](#build-scripts)
* [el-CICD Components](#el-cicd-components)
  * [el-cicd Administration Utility](#el-cicd-administration-utility)
    * [Bootstrapping Onboarding Automation Servers](#bootstrapping-onboarding-automation-servers)
    * [Refreshing Credentials](#refreshing-credentials)
    * [Building Jenkins Images](#building-jenkins-images)
    * [Updating Sealed Secrets](#updating-sealed-secrets)
    * [Extending el-cicd](#extending-el-cicd)
      * [Bootstrap Hook Scripts](#bootstrap-hook-scripts)
      * [Credential Hook Scripts](#credential-hook-scripts)
    * [Bootstrap](#bootstrap)
    * [Pipeline](#pipeline)
  * [Onboarding Automation Servers](#onboarding-automation-servers)
    * [Non-prod Onboarding Automation Server](#non-prod-onboarding-automation-server)
      * [Non-prod Onboarding Automation Server Pipelines](#non-prod-onboarding-automation-server-pipelines)
      * [non-prod-project-project-onboarding Pipeline](#non-prod-project-project-onboarding-pipeline)
      * [refresh-credentials Pipeline](#refresh-credentials-pipeline)
      * [non-prod-project-delete Pipeline](#non-prod-project-delete-pipeline)
    * [Prod Onboarding Automation Server](#prod-onboarding-automation-server)
    * [Access Considerations](#access-considerations)
* [========================================================================================](#)
* [========================================================================================](#-1)
      * [Non-prod and Prod](#non-prod-and-prod)
      * [Common Values](#common-values)
    * [el-cicd-system.config](#el-cicd-systemconfig)
      * [el-CICD Basic info](#el-cicd-basic-info)
      * [Git Repository Information](#git-repository-information-1)
        * [el-CICD Read Only Deploy Key Title](#el-cicd-read-only-deploy-key-title)
      * [Non-Prod and Prod Automation Server Namespace Postfix](#non-prod-and-prod-automation-server-namespace-postfix)
      * [General Environment Information](#general-environment-information)
      * [Environment Definitions](#environment-definitions)
      * [Jenkins Sizing and Configuration](#jenkins-sizing-and-configuration)
    * [el-cicd-bootstrap.config](#el-cicd-bootstrapconfig)
    * [Permissions](#permissions)
  * [Bootstrap](#bootstrap-1)
    * [Running the el-cicd Shell Utility](#running-the-el-cicd-shell-utility)
      * [Standing Up the Onboarding Automation Servers](#standing-up-the-onboarding-automation-servers)
      * [Refresh Credentials](#refresh-credentials)
      * [Jenkins and Jenkins Agent Image Builds](#jenkins-and-jenkins-agent-image-builds)
    * [Script Extensions](#script-extensions)
    * [el-cicd-non-prod-bootstrap.sh](#el-cicd-non-prod-bootstrapsh)
    * [el-cicd-prod-bootstrap.sh](#el-cicd-prod-bootstrapsh)
    * [el-cicd-post-github-read-only-deploy-keys.sh](#el-cicd-post-github-read-only-deploy-keyssh)

# Overview

el-CICD, pronounced like [El Cid](https://en.wikipedia.org/wiki/El_Cid), is a Configurable off the Shelf (COTS) Continuous Integration/Continuous Delivery (CICD) supporting multiple Projects of one or more microservices or components per group or team for building and deploying software onto OKD.  The system is expected to support all delivery and deployment aspects of the Software Development Lifecycle (SDLC) of projects running on OKD, from building the source and deploying into a development environment through deployment into production.

This document will cover the configuration, installation, and maintenance of el-CICD Onboarding Automation Servers.  The target audience are operational personnel that will install and maintain el-CICD, and those responsible for onboarding projects onto el-CICD.

## Fundamentals

Operational concerns with el-CICD cover the following topics:

1. **Configuring**  
   This includes all the setting files, gathering secrets, fine tuning the OKD deployment templates developers will use, and defining the builder steps for each [Code Base}(#code-base) the organization will support.

1. **Installing**  
   Running el-CICD Administration Utility to bootstrap the Onboarding Automation Servers for Non-Prod and Prod.

1. **Onboarding**
   Running the Onboarding Automation Server's onboarding pipeline to stand up a CICD Automation Server for an OKD RBAC group, if necessary, and create and configure all necessary SDLC namespaces for a [Project](foundation.md#Project).

1. **Maintenance**
   Refreshing credentials, updating [Sealed Secrets](#sealed-secrets) updating Jenkin's and Jenkins' Agent images.

## Assumptions

It is assumed the reader has a basic understanding of the SDLC, Source Control Management (SCM) solutions and Git in particular, the concepts of branching and tagging in an SCM, Docker images and containers, microservice architectures, and OKD and Kubernetes concepts.

# The el-CICD Repositories

el-CICD is designed as a COTS solution, meaning it was built as an incomplete piece of software that is meant to be adapted and configured by the end-user organization to their specific needs.  The el-CICD system consists of three repositories, including the documentation repository that this document resides in. 

**_Organizations must fork both the [el-CICD](https://github.com/elcicd/el-CICD) and the [el-CICD-config](https://github.com/elcicd/el-CICD-config) repositories._**

The [el-CICD-config](#el-cicd-config-repository) needs to be modified by the end user to adapt el-CICD to their organizational needs, and the [el-CICD](#el-cicd-config-repository) repository holds all the functional code.  These repositories are part of an OSS project that resides on a publicly hosted service, and **_no guarantee that they will continue to host el-CICD in the future is given, made, or implied_**.  Both of these repositories are pulled on every pipeline run, which has the added advantage of instant updates of functionality and configuration for CICD Automation Servers.

## el-CICD Repository

The el-CICD Repository is the functional heart of el-CICD, and is **NOT** meant to be modified by the end user.  It holds all bootstrap scripts, internal template files, BuildConfig definitions, and the [Jenkins shared library](https://www.jenkins.io/doc/book/pipeline/shared-libraries/) that forms the bulk of el-CICD's pipeline functionality.

The repository directory structure is as follows:

* **el-CICD**  
The root directory holds the main bootstrap and management utility for el-CICD, `el-cicd.sh`.
  * **resources**  
  Holds the BuildConfig YAML files, and a number of script style templates used throughout the system for deploying el-CICD Automation Servers and end user microservices.
  * **scripts**  
  Holds a number of shell scripts that define functions and functionality used by `el-cicd.sh`.
  * **vars**  
  Holds all *.groovy files that form the functionality of the pipelines in el-CICD as part of a [Jenkins Shared Library]([https://www.jenkins.io/doc/book/pipeline/shared-libraries/](https://www.jenkins.io/doc/book/pipeline/shared-libraries/)).

## el-CICD-config Repository

This repository holds all the files that end users will configure to install and run el-CICD.  Everything in this file can be modified by end users to define their install of el-CICD.

The repository directory structure is as follows:

* **el-CICD-config**
The root directory typically holds the main bootstrap configuration files defining an install of el-CICD.
  * **bootstrap**  
  Holds additional bootstrap configuration files and any user-defined bootstrap extension scripts.
  * **builder-steps**  
  Holds the [builder-steps](#builder-steps) implementations which define the Build for each Code Base.
  * **hook-scripts**  
  Holds the user-defined pipeline extensions scripts.
  * **jenkins**  
  Holds Dockerfiles that define the el-CICD Jenkins image and Jenkins Agent images.
  * **managed-okd-templates**  
  Holds definitions of Managed OKD Templates for the developers to reference.
  * **project-defs**  
  Holds every [Project Definition File](#project-definition-file).
  * **resource-quotas**  
  Holds the different ResourceQuotas that can be assigned to Project namespaces.

## el-CICD-docs Repository

Holds all the documentation for el-CICD, including this document, a developer guide, and an el-CICD tutorial.

# Configuration

## System Files

### Location

### Composing

#### Bootstrap and Secrets

#### System

#### el-cicd-meta-info

### Contents

#### Basic Information

#### Cluster Information

#### Git Repository Information

#### SDLC

##### Lifecycle Definition

##### Image Repositories

### Jenkins Configuration

#### Dockerfiles

#### Jenkins Plugins

### User-defined

## Managed OKD Resources

### Templates

### ResourceQuotas

## Project Definition File

The Project Definition File is a file that defines each Project, and **the name of the file must match the Project's name.**.  It can be written in either YAML or JSON, must be names the same as the Project, and has the following content:

```yaml
  rbacGroup: devops                    # The OKD RBAC group the Project belongs to
  scmHost: github.com                  # The SCM hostname of the Project
  scmRestApiHost: api.github.com       # RESTful API hostname for the Git provider (used for managing webhooks and deploy keys)
  scmOrganization: elcicd              # The SCM organization of the Project
  gitBranch: development               # The dev branch name of all microservices
  microServices:                       # List of microservices in Project
  - gitRepoName: Test-CICD1            # The Git repository name of the microservce
    codeBase: python                   # The codebase to build the microservice
    tester: pytest                     # Overridden tester to use during builds
    active: true                       # If the microservice is active or not
  - gitRepoName: test-cicd-stationdemo
    codeBase: java-maven
    active: true
  enabledTestEnvs:
  - qa                                 # Unordered list of test environments
  sandboxEnvs: 2                       # Number of sandboxes needed
  resourceQuotas:
    default: small.yml
    qa: medium.yml
    stg: large.yml
    prod: large.yml
  nfsShares:
  - envs:
    - qa
    - stg
    - prod
    capacity: 5Gi
    accessMode: ReadWriteMany
    exportPath: /mnt/nfs-test
    server: nfs-server.companydomain
    claimName: test-dir
```

This file will be processed every time the Project is referenced or built in a pipeline.

### OKD RBAC Groups

Regardless of how you configure OKD for user authentication with an identity provider, el-CICD Projects leverage groups as owners of Projects.  Each Project must have a group defined to be an owner, and the group will be registered as an admin for all OKD namespaces in the Project, one per environment.

### Git Project information

The Project must define the SCM (Git) host and organization of the Project.  All microservices are assumed to be on the same host and collected in the same organization.

In order to encourage good practices and standardization within a Project, the Project may only define one [Development Branch](#development-branch) name, and all microservices are expected to use it.  Committing to this branch will trigger builds, and the [Deployment Branch](#deployment-branch) for each microservice when first promoted out of Dev will be created from this branch.

### Microservices

All microservices (aka Components for more traditional, monolithic applications) belonging to the Project will be listed here.  Specific information will be

* the Git repo, from which the microservice name in the system is derived)
* the codebase of the microservice, which drives how the system will build the microservice
* By default The Build framework will look for build utility files with the following names
  * builder.groovy
  * tester.groovy
  * scanner.groovy
  * To override any of these [see below](#builder-framework)
* Whether the microservice is still active or not  
  Projects replace components regularly, but different supported versions may still use developmentally inactive components; flagging them rather than outright removing them is good practice

### Enabled Test Environments

el-CICD expects all environments to be defined before bootstrapping the system, but not all Projects will need every test environment available.  This feature allows Projects to whitelist the test environments it needs.   Only Dev, Prod, and at least one test environment are required for all Projects.  Not whitelisting a test environment will default in selecting the first one in the list of [available test environments](#general-environment-information).

### Sandbox Environments

The number sandbox environments needed by the Project.

el-CICD can support any combination of build, test, and scanning per codebase.  The following will describe the el-CICD's Builder Framework, and how to extend it as needed.

## Code Base Framework

### Jenkins Agents

### Builder Steps

The **_builder-steps_** directory holds the functional files that are loaded and executed for each build.


![Figure 7: The builder-steps Directory](images/readme/builder-steps-directory.png)

**Figure 7**  
 _The builder-steps directory_

#### Code Base Folders

Each codebase must have a folder of the same name.created in the _builder-steps_ directory, and it must contain at least one builder, tester, and scanner script for the codebase to execute when building.  Even if the codebase doesn't execute the step, an empty script must be defined for the component.  The folders many also contain other folders or files to support builds; e.g. in Figure 7 above, the `r-lang` codebase has a `resources` folder for holding files defining linting instructions.

#### Build Scripts

The builder framework is made up of three basic steps for each Build: building, testing, and scanning.  By default, the framework will look inside the codebase folder and look for the following files for each step:

* **Building**: `builder.groovy`
* **Testing**: `tester.groovy`
* **Scanning**: `scanner.groovy`

For microservices defined in a [Project Definition File](#Project-definition-file), there is no need to specifically name any of the defaults.  If a step is to be overridden by a file that does not follow the above naming conventions, then it does have to be named:

```yaml
- gitRepoName: Test-CICD1            # The Git repository name of the microservce
  codeBase: python                   # The codebase to build the microservice
  tester: pytest                     # Overridden tester to use during builds
  active: true                       # If the microservice is active or not
```

The above snippet from the [Project Definition File](#Project-definition-file) example above specifies that the `pytest.groovy` script (found in the `python` codebase folder) should be executed during the testing step of The Build.

Developers need to follow certain conventions for their microservice Projects to integrate into el-CICD.  In particular:

* **A standard of one image produced per Git repository**  
  It will be assumed that only one microservice will be defined per Git repository per Project.  This is not the same as one image deployed per Git repository; i.e. deployment configurations for supporting images, such as databases, or multiple configurations of the same image built, are perfectly reasonable deployment strategies.
* **A Dockerfile must exist in the root directory of the microservice or component to be built**  
  Every OKD BuildConfig will use the binary docker strategy to create and push an image to the Dev environment Image Repository.  el-CICD does not currently manage builds strictly for building artifacts consumed for builds by other microservices.
* **All OKD deployment resources will be placed in a**_.openshift_**directory under the root directory of the microservice.**

OKD Template reuse and patching via `kustomize` is relied on heavily for ease of use, but not necessary.

# el-CICD Components

![Figure 2: Environment Flow](images/readme/components.png)

**Figure 2**  
_The relationship between the basic components that comprise el-CICD_

## el-cicd Administration Utility

The el-cicd Administration Utility, located in root directory of the [el-CICD Repository](#el-cicd-repository) will drive the bootstrapping of el-CICD [Onboarding Automation Servers](#Onboarding Automation Server), refresh their credentials, and build Jenkins and Jenkins' Agent images.

```text
Usage: el-cicd.sh [OPTION] [root-config-file]

el-CICD Install Utility

Options:
    -N,   --non-prod:        bootstraps Non-prod el-CICD Onboarding Automation Server
    -n,   --non-prod-creds:  refresh Non-prod el-CICD Onboarding Automation Server credentials
    -P,   --prod:            bootstraps Prod el-CICD Onboarding Automation Server
    -p,   --prod-creds:      refresh Prod el-CICD Onboarding Automation Server credentials
    -c,   --cicd-creds:      run the refresh-credentials pipeline
    -s,   --sealed-secrets:  reinstall/upgrade Sealed Secrets
    -j,   --jenkins:         only build el-CICD Jenkins image
    -a,   --agents:          only build el-CICD Jenkins agent images
    -A,   --jenkins-agents:  build el-CICD Jenkins and Jenkins agent images
          --help:            display this help text and exit

root-config-file:
    file name or path to a root configuration file relative the root of the el-CICD-config directory
```

### Bootstrapping Onboarding Automation Servers

### Refreshing Credentials

### Building Jenkins Images

### Updating Sealed Secrets

### Extending el-cicd

#### Bootstrap Hook Scripts

#### Credential Hook Scripts

### Bootstrap

### Pipeline

## Onboarding Automation Servers

### Non-prod Onboarding Automation Server

Non-prod Onboarding Automation Servers are responsible for deploying, configuring, and setting the credentials of Non-prod CICD Automation Servers, and onboard and remove Projects.

**ACCESS TO A NON-PROD ONBOARDING AUTOMATION SERVER SHOULD BE RESTRICTED TO CLUSTER ADMINS ONLY.**  

All Onboarding Automation Servers require Git site-wide access, and have service accounts with OKD cluster admin privileges.  Allowing unprivileged users direct access to an Onboarding Automation Server would constitute security risk.


#### Non-prod Onboarding Automation Server Pipelines

![Figure 9: Build and Deploy Microservices](images/readme/el-cicd-non-prod-onboarding-master.png)

**Figure 9**
_el-CICD Non-prod Automation Server pipelines_

#### non-prod-project-project-onboarding Pipeline

This pipeline is responsible for onboarding the necessary resources to support a Project's Non-prod SDLC.

| Parameters             | Description                                                                     |
| ---------------------- | ------------------------------------------------------------------------------- |
| PROJECT_ID             | The Project ID                                                                  |
| REBUILD_NON_PROD       | If true, destroy and recreate all Project Non-prod SDLC namespaces environments |
| REBUILD_SANDBOXES_ONLY | If true, destroy and recreate all Project Sandbox namespace environments        |

* Read the [Project Definition File](#project-definition-file)
* Create a namespace for the CICD Automation Server if it doesn't exist
  * `<RBAC-group>-el-cicd-non-prod-master`
* Deploy the CICD Automation Server for the Project's RBAC Group, if necessary
* Create all Non-prod Pipelines
  * [Build and Deploy Microservices](#build-and-deploy-microservices)
  * [Create Release Candidate](#create-release-candidate)
  * [Promotion/Removal](#promotionremoval)
  * [Redeploy/Removal](#redeployremoval)
  * [Redeploy Release Candidate](#redeploy-release-candidate)
* Add all necessary credentials to the CICD Automation Server for all Non-prod Image Repositories
* Create [Build-to-Dev](#build-and-deploy-microservices) Pipelines, one for each microservice
* (Re)Create the Project's SDLC namespaces, if necessary or requested
  * Create any NFS shares for each namespace, if defined
  * Set the assigned ResourceQuota on each namespace, if defined
* Create Sandbox Environments, if any
* Push a new read/write deploy key for each microservice to its Git repository and the CICD Automation Server

 ```bash
 curl https://<RBAC-group>-el-cicd-non-prod-master/job/el-cicd-non-prod-onboarding-master/job/el-cicd-non-prod-onboarding-master-non-prod-project-onboarding/buildWithParameters --user <OKD_SERV_ACCT>:<SERV_ACCT_TOKEN> --data PROJECT_ID=my-project-id
 ```

#### refresh-credentials Pipeline

This pipeline will refresh all credentials on every CICD Automation Server referenced by all Projects defined in el-CICD-config.

| Parameters | Description |
| ---------- | ----------- |
| N/A        |             |

* Loops through every Project, and if the CICD Automation Server for the RBAC group exists
  * Copies the ConfigMap containing the latest el-CICD system information into the CICD Automation Server namespace
  * Copies the pull Secrets for all Non-prod Image Repositories into the CICD Automation Server namespace
  * Updates all deploy keys and pull secrets on the CICD Automation Server (Jenkins credentials)
  * If the Project's Non-prod SDLC namespace exists
    * Copies the pull Secrets into each appropriate namespace
      * e.g. the Dev Image Repository's pull Secret into the Dev namespace environment
    * 
 
#### non-prod-project-delete Pipeline

### Prod Onboarding Automation Server

Prod Onboarding Automation Servers are responsible for deploying, configuring, and setting the credentials of Prod CICD Automation Servers, and onboard Projects.

### Access Considerations

**ACCESS TO ONBOARDING AUTOMATION SERVERS SHOULD BE RESTRICTED TO CLUSTER ADMINS ONLY.**  
All Onboarding Automation Servers need Git site-wide access, as well act as OKD cluster admins.  Allowing unprivileged users direct access to an Onboarding Automation Server would constitute security risk.


# ========================================================================================

# ========================================================================================

#### Non-prod and Prod

#### Common Values

After forking the el-CICD repositories, el-CICD needs to be configured.  This requires defining which such information as test environments your engineering cluster will support, specifying the cluster's wildcard domain, creating and/or deciding which image repositories will back each environment, gathering the Git and Image Repository tokens as secrets for access, credentials, and sizing information for your Jenkins instances.  There are two files, [el-cicd-system.config](#el-cicd-bootstrapconfig) and [el-cicd-bootstrap.config](#el-cicd-secretsconfig), and both are sourced during bootstrapping.

### el-cicd-system.config

This configuration file defines most of the values needed to configure an el-CICD installation, as well as defining the SDLC environments and promotion flow, among other things.  The file are sourced when running either bootstrap shell script for the Onboarding Automation Servers, and then used to create a ConfigMap holding this information in every CICD Jenkins namespace subsequently created by the system.

#### el-CICD Basic info

```properties
  EL_CICD_MASTER_NAMESPACE=el-cicd-non-prod-master
  EL_CICD_MASTER_NODE_SELECTORS=

  EL_CICD_PROD_MASTER_NAMEPACE=el-cicd-prod-master
  EL_CICD_PROD_MASTER_NODE_SELECTORS=

  CLUSTER_WILDCARD_DOMAIN=my.cluster.com

  EL_CICD_META_INFO_NAME=el-cicd-meta-info
```

This section describes the namespaces and node selectors of the engineering (Non-prod) and production (Prod) el-CICD [Onboarding Automation Servers](#onboarding-automation-server).  The cluster's wildcard domain and the name of the ConfigMap that this configuration information will be stored on OKD are also here.

Note that except for the node selectors, for the most part this information can be left as is, unless you intend to install multiple instances on the same cluster, in which case each will need it's own, unique namespace.  The wildcard domain is the exception, as each cluster will most likely have its own.

#### Git Repository Information

```properties
  GIT_CREDS_POSTFIX=git-repo-private-key

  EL_CICD_GIT_REPO=git@github.com:elcicd/el-CICD.git
  EL_CICD_BRANCH_NAME=master
  EL_CICD_READ_ONLY_GITHUB_PRIVATE_KEY_ID=el-cicd-read-only-git-repo-private-key

  EL_CICD_UTILS_GIT_REPO=git@github.com:elcicd/el-CICD-utils.git
  EL_CICD_UTILS_BRANCH_NAME=master
  EL_CICD_UTILS_READ_ONLY_GITHUB_PRIVATE_KEY_ID=el-cicd-utils-read-only-git-repo-private-key

  EL_CICD_PROJECT_INFO_REPOSITORY=git@github.com:elcicd/el-CICD-Project-repository.git
  EL_CICD_PROJECT_INFO_REPOSITORY_BRANCH_NAME=master
  EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_GITHUB_PRIVATE_KEY_ID=el-cicd-Project-info-repository-git-repo-private-key

  GIT_SITE_WIDE_ACCESS_TOKEN_ID=git-site-wide-access-token
```

This section of the configuration file covers the location of the Git repositories [el-CICD](#el-cicd-repository) [el-CICD-utils](#el-cicd-utils-repository) and [el-CICD-Project-repository](#el-cicd-Project-repository)  All will need to be updated to match where you have decided to fork these repositories, as each is cloned for every pipeline run.

* **GIT_CREDS_POSTFIX**  
This is appended to all el-CICD credential IDs stored in Jenkins for GitHub.
* ***_GIT_REPO**  
The url of the el-CICD Git repositories.
* ***_REPOSITORY_BRANCH_NAME**  
These variables define the branch to check out for each el-CICD repository.
* ***_READ_ONLY_GITHUB_PRIVATE_KEY**  
These Jenkins credential IDs are passed onto Project specific Jenkins for read only access to the el-CICD repositories for each Non-prod and Prod Automation Server.
* **GIT_SITE_WIDE_ACCESS_TOKEN_ID**  
This ID references the token stored in Jenkins for an administrative service account for access to all Project Git repositories.  This is needed in order to add a writable deploy key and a webhook for automated builds for each microservice Git repository.  More on this will be described below in the [el-cicd-bootstrap.config](#el-cicd-secretsconfig)

##### el-CICD Read Only Deploy Key Title

```properties
  EL_CICD_DEPLOY_NON_PROD_KEY_TITLE=el-cicd-non-prod-deploy-key
  EL_CICD_DEPLOY_PROD_KEY_TITLE=el-cicd-prod-deploy-key
```

These deploy keys are the titles used to read only store access keys up on the Git provider for el-CICD access.  These need to be unique per installed Onboarding Automation server.  Every time the bootstrap script is run, it will look for a deploy key with the given title, remove it if it's there, and place a a deploy key with this title for use.  For example, if el-CICD is installed on multiple production clusters for purposes of deploying the applications with failover capability per region, a unique _EL_CICD_DEPLOY_PROD_KEY_TITLE_ will need to be provided to each.

#### Non-Prod and Prod Automation Server Namespace Postfix

```properties
  EL_CICD_GROUP_NAMESPACE_POSTFIX=cicd-non-prod
  EL_CICD_GROUP_NAMESPACE_POSTFIX=cicd-prod
```

Namespaces for the each RBAC Group's namespace will have these values appended to the RBAC group name; e.g. if a Project's group is _devops_, the resulting Non-prod and Prod Automation Servers will reside in _devops-cicd-non-prod_ and  _devops-cicd-prod_, respectively.

#### General Environment Information

```properties
  DEV_ENV=DEV

  TEST_ENVS=<TEST_ENV_1>:...:<TEST_ENV_N>

  PROD_ENV=PROD
```

The values represent the general names and SDLC flow of the installed el-CICD environments.

* **DEV_ENV**
Name of the Dev environment.  This must be defined.
* **TEST_ENVS**
Colon separated list of test environment.  As many can be defined as the needs of the organization dictate.  Each Project needs at least one test environment, but may disable as many or none of the others.
* **PROD_ENV**
The name of the Prod environment.  This must be defined.

The SDLC workflow will be defined by the system as

`<DEV_ENV> -> <TEST_ENVS> -> PROD_ENV`

Thus, for

`TEST_ENVS=QA:UAT:STG`

This will define a set of environments with the following SDLC flow:

`DEV -> QA -> UAT -> STG -> PROD`

#### Environment Definitions

```properties
  DEV_IMAGE_REPO_DOMAIN=docker.io
  DEV_IMAGE_REPO_USERNAME=elcicddev
  DEV_IMAGE_REPO=docker.io/elcicddev
  DEV_IMAGE_REPO_PULL_SECRET=el-cicd-image-repo-dev-pull-secret
  DEV_IMAGE_REPO_ACCESS_TOKEN_ID=image-repo-dev-access-token
  DEV_NODE_SELECTORS=

  <TEST_ENV>_IMAGE_REPO_DOMAIN=docker.io
  <TEST_ENV>${el.cicd.IMAGE_REPO_USERNAME_POSTFIX}=elcicdnonprod
  <TEST_ENV>${el.cicd.IMAGE_REPO_POSTFIX}=docker.io/elcicdnonprod
  <TEST_ENV>${el.cicd.IMAGE_REPO_PULL_SECRET_POSTFIX}=el-cicd-image-repo-non-prod-pull-secret
  <TEST_ENV>${el.cicd.IMAGE_REPO_ACCESS_TOKEN_POSTFIX}=image-repo-non-prod-access-token
  <TEST_ENV>_NODE_SELECTORS=

  PROD_IMAGE_REPO_DOMAIN=docker.io
  PROD_IMAGE_REPO_USERNAME=elcicdprod
  PROD_IMAGE_REPO=docker.io/elcicdprod
  PROD_IMAGE_REPO_PULL_SECRET=el-cicd-image-repo-prod-pull-secret
  PROD_IMAGE_REPO_ACCESS_TOKEN_ID=image-repo-prod-access-token
  PROD_NODE_SELECTORS=
```

After the environment name and SDLC flow is defined, each environment's configuration must be completed.

* **\<ENV>_IMAGE_REPO_DOMAIN**  
Image repository domain.
* **\<ENV>${el.cicd.IMAGE_REPO_USERNAME_POSTFIX}**  
Image repository username or organization ID
* **\<ENV>${el.cicd.IMAGE_REPO_POSTFIX}**  
Image repository url; i.e *_IMAGE_REPO_DOMAIN/*${el.cicd.IMAGE_REPO_USERNAME_POSTFIX}
* **\<ENV>${el.cicd.IMAGE_REPO_PULL_SECRET_POSTFIX}**  
Image pull secret name; secret is generated at startup with this name.
* **\<ENV>${el.cicd.IMAGE_REPO_ACCESS_TOKEN_POSTFIX}**  
Jenkins credentials ID referring to the pull secret

The above values are each prepended with the name of each environment defined in the previous section.  For a test environment called QA, you're final config entry would look like the following:

```
  QA_IMAGE_REPO_DOMAIN=docker.io
  QA_IMAGE_REPO_USERNAME=elcicdnonprod
  QA_IMAGE_REPO=docker.io/elcicdnonprod
  QA_IMAGE_REPO_PULL_SECRET=el-cicd-image-repo-non-prod-pull-secret
  QA_IMAGE_REPO_ACCESS_TOKEN_ID=image-repo-non-prod-access-token
  QA_NODE_SELECTORS=
```

Typical installations might have a Dev, QA (covering all test environments), and Prod Image Repository, but it is also possible have a single Image Repository shared among all environments, or an Image Repository per environment.  Regardless, an entry for each named environment must be defined separately.

#### Jenkins Sizing and Configuration

```properties
  JENKINS_MEMORY_LIMIT=4Gi
  JENKINS_VOLUME_CAPACITY=4Gi
  JENKINS_DISABLE_ADMINISTRATIVE_MONITORS=true
```

Sizing information in memory and persistent storage capacity for each Jenkins created by el-CICD.


### el-cicd-bootstrap.config

A secondary configuration file is used by el-CICD on bootstrap, and it holds a few minor configuration values that don't need to be referenced from the running el-CICD system or Project environments, as well as a number variables that provide paths to files that hold the actual secret SSH keys and access tokens that will be onloaded into Jenkins.

Depending on how you choose to manage your different Onboarding Automation Servers, you can either reuse the keys among them or keep individual keys for each server.  If you keep individual keys per server, then you will need to change the titles used to push them into the SCM so they do not overwrite each other.

```properties
  GIT_PROVIDER=github

  # Domain to call Git host provider RESTful API
  EL_CICD_GIT_API_DOMAIN=api.github.com

  # Organization/account where el-CICD repos are hosted
  EL_CICD_ORGANIZATION=elcicd

  SECRET_FILE_DIR=../cicd-secrets

  EL_CICD_SSH_READ_ONLY_PUBLIC_DEPLOY_KEY_TITLE=el-cicd-read-only-public-key
  EL_CICD_SSH_READ_ONLY_DEPLOY_KEY_FILE=${SECRET_FILE_DIR}/el-CICD-deploy-key

  EL_CICD_UTILS_SSH_READ_ONLY_PUBLIC_DEPLOY_KEY_TITLE=el-cicd-utils-read-only-public-key
  EL_CICD_UTILS_SSH_READ_ONLY_DEPLOY_KEY_FILE=${SECRET_FILE_DIR}/el-CICD-utils-deploy-key

  EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_DEPLOY_KEY_TITLE=el-cicd-Project-info-repository-read-only-public-key
  EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_DEPLOY_KEY_FILE=${SECRET_FILE_DIR}/el-cicd-Project-info-repository-github-deploy-key

  EL_CICD_GIT_REPO_ACCESS_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-git-repo-access-token

  DEV_PULL_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-dev-pull-token

  QA_PULL_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-non-prod-pull-token

  UAT_PULL_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-non-prod-pull-token

  STG_PULL_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-non-prod-pull-token

  PROD_PULL_TOKEN_FILE=${SECRET_FILE_DIR}/el-cicd-prod-pull-token
```

* **EL_CICD_GIT_API_DOMAIN  
  EL_CICD_ORGANIZATION**  
The el-CICD SCM host and organization.  Note that the system is built assuming the el-CICD repositories are stored in the same SCM as the Project repositories it will be managing.
* **EL_CICD_SSH_READ_ONLY_PUBLIC_DEPLOY_KEY_TITLE EL_CICD_UTILS_SSH_READ_ONLY_PUBLIC_DEPLOY_KEY_TITLE
EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_DEPLOY_KEY_TITLE**  
The title to use when pushing the read only key to el-CICD.  If you don't wish to use the same read-only per Onboarding Automation Server installation, then you'll need a separate name per installation.
* **EL_CICD_SSH_READ_ONLY_DEPLOY_KEY_FILE  
  EL_CICD_UTILS_SSH_READ_ONLY_DEPLOY_KEY_FILE  EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_DEPLOY_KEY_FILE**  
The path to the read-only private deploy key for the el-CICD repositories.  The system assumes the *.pub key is located in the same directory for pushing to the SCM.
* **EL_CICD_GIT_REPO_ACCESS_TOKEN_FILE**  
An access token (**not** an ssh key) to an administrative account for the SCM.  This token will live in the Onboarding Automation Server.  For this reason, only administrators of the DevOps should have access to this server.  Write tokens for each Project microservice's repository will be confined to the group that owns the Project.
* **<ENV_NAME>_PULL_TOKEN_FILE**  
Path to the file holding the access token(s) to the Image Repository for each environment.  These will be used for the Build and for all image Deployments, and these tokens need push and pull access to each repository.  As the example above shows, each test environment must be defined separately, even if all the test environments use the same repository.

### Permissions

It is strongly suggested that only responsible DevOps resources have access to the el-CICD repositories (`el-CICD` and `el-CICD-utils` and `el-CICD-Project-information-repository`) as well the Onboarding Automation Servers.  This ensures only DevOps resources can define system level changes, or have access across the Git repositories.  For the `el-CICD-Project-information-repository`, it also ensures Projects can't edit each other's Project definition files.


## Bootstrap


Once each _*.config_ file has all the values properly entered, and all Image Repository pull and Git repository deploy tokens are saved in their proper locations, the bootstrap scripts can be run.

There are two bootstrap scripts, one each for the Non-Prod and Prod Onboarding Automation Servers.  This allows for the greatest flexibility on installation of the servers, perhaps more than once, on different clusters.

A typical, minimal installation of OKD has three clusters, a lab cluster to test cluster configuration changes and upgrades, a production quality cluster to support software development and/or application deployments, and a production quality cluster for running applications in production.  Many times more than one production cluster is deployed to support multiple regions and/or failover, or perhaps engineering groups don't share the same cluster during software development or testing.  The modularity of the bootstrap scripts allows for easy installation of el-CICD in as many clusters for as many purposes as needed.

### Running the el-cicd Shell Utility

#### Standing Up the Onboarding Automation Servers

#### Refresh Credentials

#### Jenkins and Jenkins Agent Image Builds

### Script Extensions

### el-cicd-non-prod-bootstrap.sh

The el-CICD Non-prod Automation Onboarding Server bootstrap script is for setting up a production CICD server for onboarding Projects into a engineering OKD cluster.  Executing the script results in the following actions:

1. Source the *.config files
1. Have the user confirm the OKD cluster's wildcard domain
1. Run the script for pushing el-CICD repository read only public keys to the Git provider
1. Have the user confirm deletion of the el-CICD Non-prod master namespace, if it exists
    * **NOTE**: failure to delete the old namespace will cause the script to exit
1. Stand up a new persistent Jenkins instance to act as the Onboarding Automation Server
1. Install Sealed Secrets locally and on the cluster
    1. If Sealed Secrets is not already installed, installation proceeds immediately
    1. User will confirm installation of Sealed Secrets locally and on the cluster if Sealed Secrets has been installed before
    * **NOTE**: Users should check version numbers and release notes before upgrading
1. Wait until Jenkins is ready
1. Create all necessary Sealed Secrets for image pull secrets for each environment
1. Push all necessary credentials to Jenkins

### el-cicd-prod-bootstrap.sh

The el-CICD Prod Automation Onboarding Server bootstrap script is for setting up a production CICD server for onboarding Projects into a production OKD cluster.  Executing the script result in the following actions:

1. Source the *.config files
1. Have the user confirm the OKD cluster's wildcard domain
1. Have the user confirm deletion of the el-CICD Prod master namespace, if it exists
    * **NOTE**: failure to delete the old namespace will cause the script to exit
1. Stand up a new persistent Jenkins instance to act as the Onboarding Automation Server
1. Install Sealed Secrets locally and on the cluster
    1. If Sealed Secrets is not already installed, installation proceeds immediately
    1. User will confirm installation of Sealed Secrets locally and on the cluster if Sealed Secrets has been installed before
    * **NOTE**: Users should check version numbers and release notes before upgrading
1. Wait until Jenkins is ready
1. Create all necessary Sealed Secrets for image pull secrets for the Prod environment
1. Push all necessary credentials to Jenkins for Prod deployments

**NOTE**: el-CICD read-only public keys are **NOT** pushed to Git with this script.  Read only deploy keys are the only access necessary for deployments into production, so current configuration assumes the same private key used in the Non-prod Onboarding Automation Server will be used here.

### el-cicd-post-github-read-only-deploy-keys.sh

This script is shared between the two bootstrap scripts for pushing deployment keys to the three el-CICD repositories.  It first deletes the old keys, if any, on the Git SCM host, and the pushes the new, public keys to the host.  This allows all pipelines on every el-CICD server to access the el-CICD repositories in a read-only mode.

