  
  
**Overview of features and documentation for understanding, operating, and developing within el-CICD.**

* [Preamble](#preamble)
* [License](#license)
* [PREFACE](#preface)
* [el-CICD Documentation](#el-cicd-documentation)
* [TODO](#todo)

## Preamble

This document is part of the el-CICD Project, a complete CICD COTS solution for [OKD, The Community Distribution of Kubernetes that powers Red Hat Openshift](https://www.okd.io/)

Copyright (C) 2021 Evan "Hippy" Slatis  
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

## PREFACE

The documents in this repository describes the motivation, design, and implementation of a fully featured CICD COTS solution for use on either the upstream OKD or on Red Hat® OpenShift®, either 3.11 or 4.x.  Wherever OKD is referenced, OpenShift may be safely inferred.  Barring some minor configuration, there should be no difference in how the the system works on either platform.

el-CICD supports the following features:

* **DevOps Support**
  * Automated bootstrapping of servers
  * Automated Jenkins And Jenkins Agent image builds
  * Automated and extensible framework for setting and rotating credentials
  * Extensible framework of build and deployment pipelines
  * Easy to enforce standards within a project or across an organization
  * Automated and configurable support for creation and management of NFS Persistent Volumes
  * Automated and configurable support for management of ResourceQuotas per Project and namespace
  * Configurable set of SDLC environments per installation and, to a lesser degree, per Project
  * Automated support for deployment, rollback, and roll forward of complete applications in production
  * Simplified support of applications to more than one cluster
  * Hotfixing support for deployments in production

* **Development Support**
  * Automated building, testing, scanning, and deployment for libraries and microservices
  * Vastly simplified deployment configuration framework for developers: development team focus should remain on business requirements
  * Sandbox deployments for developers to test
  * Deployment of encrypted Secrets from Git
  * Automated branching, tagging, and synchronization of deployment configurations in Git and Docker image repositories
  * Automated promotion of images across SDLC environments and/or OKD clusters
  * Roll-forward and roll-back functionality
  * Incremental and versioned patching of deployments in downstream SDLC environments

## el-CICD Documentation

* [**Foundations**](foundations.md)  
  Explains the basic concepts, design, and architecture behind el-CICD.  Also lists supporting, 3rd party projects incorporated into el-CICD.

* [**Operating Manual**](operating-manual.md)  
  For cluster and CICD server administrators explaining el-CICD DevOps.  How to bootstrap, maintain, and manage el-CICD.

* [**Developer Guide**](developer-quide.md)  
  Everything a developer needs to know to integrate their Projects into el-CICD for fully automated SDLC support and deployment from commiting to their Development Branch to creating a Release Candidate for promotion to Prod.

* [**Tutorial**](tutorial.md)  
  The easiest and fastest way to learn most of what el-CICD has to offer on your own, local cluster using [Red Hat CodeReady Containers](https://developers.redhat.com/products/codeready-containers/overview).

## TODO

Features not supported, but coming soon:

* **GitLab and Bitbucket support**
  * Only GitHub is currently supported

* **Vanilla Kubernetes deployments**
  * Final deployments of end-user projects can be Kubernetes neutral, but el-CICD currently installs and runs only on OKD/OpenShift clusters

* **Helm support**
  * el-CICD provides an easy to use and flexible system of templated Kubernetes and OKD Resources, but we realize this is not the be all/end all for defining deployment configurations.

* **More fine-grained RBAC control of SDLC environments and promotions**
  * Access to development and test environments within a Project is currently restricted for a single RBAC group.  In the future, el-CICD will support differing group access definitions between development and test environments and pipelines.