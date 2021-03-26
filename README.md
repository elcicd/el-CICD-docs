# el-CICD Introduction and Documents

Overview of features, and [supporting documents](#supporting-documents) for understanding, operating, and developing for el-CICD.

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

## PREFACE

The documents in this repository describes the motivation, design, and implementation of a fully featured CICD COTS solution for use on either the upstream OKD or on Red Hat® OpenShift®, either 3.11 or 4.x.  For the remainder of the document wherever OKD is referenced, OpenShift may be safely inferred.  Barring some minor configuration, there should be no difference in how the the system works on either platform.

el-CICD supports the following features:

* Configurable set of SDLC environments per installation and, to a lesser degree, per Project
* Extensible scripting framework for bootstrapping el-CICD
* Extensible build framework by language and/or framework
* Extensible framework for el-CICD pipelines
* Simplified deployment configuration framework for developers, minimizing code and configuration required so team focus remains on business requirements
* Sandbox deployments for developers
* Configurable support for automated creation of NFS Persistent Volumes
* Configurable support for automated application of ResourceQuota definitions per environment
* Automated branching, tagging, and synchronization of deployment configurations in Git and Docker image repositories
* Automated promotion of images across SDLC environments and/or OKD clusters
* Roll-forward and roll-back functionality within environments, including full production versions
* Incremental and versioned patching of deployments in downstream SDLC envrionments
* Support for promotions, and deployments into production
* Automated versioning of applications across a group of microservices in production
* Incremental deployment patching into production

Features not supported, but on the TODO list:

* GitLab and Bitbucket support
* Helm support
* More fine-grained RBAC control of SDLC environments and promotions
* Support multiple Production deployment environments (e.g. different regions may require different configurations)
* Parallel development Projects (e.g. hotfix or alternating team releases)

## Supporting Documents

* [Foundations](foundations.md)  
  Explains the basic concepts and architecture of el-CICD.  Also lists supporting, 3rd party projects incorporated into el-CICD.  
* [Operations Manual](operating-manual.md)  
  For cluster administrators.  How to bootstrap, maintain, and manage el-CICD.
* [Developer Guide](developer-quide.md)  
  Everything a developer needs to know to integrate their Projects into el-CICD for fully automated SDLC support and deployment from commiting to their Development Branch to deployment to Prod.