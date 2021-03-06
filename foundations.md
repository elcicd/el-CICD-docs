
# el-CICD Foundations

## Preamble

This document is part of the el-CICD Project, a complete CICD system for the OKD Container Platform.

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

# TABLE OF CONTENTS

* [el-CICD Foundations](#el-cicd-foundations)
  * [Preamble](#preamble)
  * [License](#license)
* [TABLE OF CONTENTS](#table-of-contents)
* [Overview](#overview)
  * [Key Characteristics](#key-characteristics)
  * [Goals](#goals)
  * [Assumptions](#assumptions)
  * [CICD Patterns and Concepts](#cicd-patterns-and-concepts)
    * [Concepts](#concepts)
    * [Environments](#environments)
      * [Dev Environment](#dev-environment)
      * [Test Environments](#test-environments)
      * [Pre-prod Environment](#pre-prod-environment)
      * [Prod Environment](#prod-environment)
    * [Project](#project)
    * [Build Once, Deploy Many](#build-once-deploy-many)
    * [Continuous Integration](#continuous-integration)
      * [Development Branch](#development-branch)
      * [Code Base](#code-base)
      * [The Build](#the-build)
        * [Build](#build)
        * [Test](#test)
        * [Scan](#scan)
        * [Assemble](#assemble)
        * [Deploy](#deploy)
      * [Standardization](#standardization)
    * [Continuous Delivery](#continuous-delivery)
    * [Continuous Deployment](#continuous-deployment)
  * [Tools](#tools)
    * [Project Definition Repository](#project-definition-repository)
    * [Source Control Management (SCM)](#source-control-management-scm)
    * [Scanner](#scanner)
    * [Artifact Repository](#artifact-repository)
    * [Automation Server](#automation-server)
      * [Pipeline](#pipeline)
    * [Container Orchestration Platform](#container-orchestration-platform)
      * [Namespaces](#namespaces)
    * [Secret Encryption Tool](#secret-encryption-tool)
  * [CICD Development Workflow Patterns](#cicd-development-workflow-patterns)
    * [Build-library](#build-library)
    * [Build-to-Dev](#build-to-dev)
    * [Promotion](#promotion)
      * [Deployment Branch](#deployment-branch)
      * [Deployment Patching](#deployment-patching)
    * [Component Rollback and Roll-Forward](#component-rollback-and-roll-forward)
    * [Deploy To Production](#deploy-to-production)
      * [Application, or Project, Releases](#application-or-project-releases)
      * [Pre-prod](#pre-prod)
      * [Release Candidate](#release-candidate)
      * [Deploy-to-Prod](#deploy-to-prod)
        * [Release Version](#release-version)
          * [Release Region](#release-region)
        * [Production Rollback/Forward/Deployment Patching](#production-rollbackforwarddeployment-patching)
      * [Hotfixing](#hotfixing)
  * [Supporting Projects](#supporting-projects)
    * [Git](#git)
    * [GitHub](#github)
    * [Jenkins](#jenkins)
    * [skopeo](#skopeo)
    * [DockerHub](#dockerhub)
    * [OKD](#okd)
    * [Kustomize](#kustomize)
    * [SealedSecrets](#sealedsecrets)

# Overview

el-CICD, pronounced like [El Cid](https://en.wikipedia.org/wiki/El_Cid), is a Configurable off the Shelf (COTS) Continuous Integration/Continuous Delivery (CICD) supporting multiple Projects of one or more microservices or components per group or team for building and deploying software onto OKD.  The system is expected to support all build and deployment aspects of the Software Development Lifecycle (SDLC) of projects running on OKD, from building the source and deploying into a development environment through deployment into production.

This document will cover the conceptual and architectural underpinnings of el-CICD.  The target audience are readers that wish to understand the concepts and external software projects that el-CICD is supported by and organized around.

## Key Characteristics

Key characteristics the system was designed and implemented with include:

* Support and enforcement of standards recognized as software development best practices
* Ease of maintenance for operators
* Ease of integration for software development teams
* Transparency to all users
* The ability to collect and collate metrics from all software development Projects
* Full automation of builds and deployments of applications onto OKD

## Goals

The high level goal of el-CICD is to create an automated, repeatable, and easy to use CICD system for teams to deliver source code and encourage standards and best practices.  This in turn allows development teams to focus less on the technical details of software delivery and the platform it runs on and more on the business requirements of their Projects.  Ultimately it should make software development teams more productive, more agile, increase velocity, and increase quality with minimal effort.

## Assumptions

It is assumed the reader has a basic understanding of the SDLC, Source Control Management (SCM) solutions and Git in particular, the concepts of branching and tagging in an SCM, Docker images and containers, microservice architectures, and OKD and Kubernetes concepts.

## CICD Patterns and Concepts

### Concepts

CICD is the process of building software as soon as source code is committed to an SCM, and and then deploying the software after a successful build.  Ideally it encompasses the execution of builds, and the deployment into any and all environments through production supported by the SDLC of a team and/or organization.

el-CICD was designed and built to easily and transparently support and the following concepts.  These concepts are mostly presented in the context of el-CICD, and are not meant to be a comprehensive discussion of all things CICD.

### Environments

A SDLC typically includes a number of deployment stages before ultimately being released to production.  Each stage should be hosted in its own, isolated environment, although sometimes environments are created to support more than one SDLC stage; e.g. a quality assurance (QA) environment being used for user acceptance testing (UAT), and a staging environment (stg) doubling as a load testing and Pre-prod(uction) environment.

Environments are a key concept that needs to be supported by any CICD system.  While deployments to each environment should ideally be exactly the same from Dev to Prod, there are many reasons why this is rarely true based on need and other practical matters.  Best practices are to minimize the differences between environments, and the closer to a production environment a deployment gets the closer the environment should resemble production.  While not always the case, environments are usually organized as a linear sequence; e.g. from Dev to QA to Stage to Prod.  el-CICD supports a configurable, linear sequence of environments, with a few exceptions to be described below.

![Figure: Environment Flow](images/foundations/environments.png)

**Figure 1**  
 _Environment flow from Git to Prod_

#### Dev Environment

The Dev, or Development, Environment represents the initial deployment of a software Project immediately after a build.  It should be a direct reflection of the source code as it currently exists in its SCM repository code at all times.  In general, if at any time the current build in Dev does not reflect the current state of the SCM, then [The Build](#the-build) is considered to be broken.  This is at the very heart of what continuous integration means.

#### Test Environments

Test can represent one or more environments.  Examples include:

* **Quality Assurance (QA)**: for the testing of whether the software meets its functional and business requirements
* **User Acceptance Testing (UAT)**: for the testing by end users as to whether it meets their requirements for being usable
* **Stage (Stg):** A catch-all environment for performance or load testing

Which environments a Project actually uses depends on such factors as the size and needs of the Project and the organization.

#### Pre-prod Environment

The Pre-prod environment is a special kind of Test Environment, and is the penultimate SDLC environment before deployment to Prod.  Ideally it is as close to the Production Environment as possible, and it is typically used for testing that the production deployment configuration works, and that the software in the production will work as expected.

#### Prod Environment

The final environment, Prod, or Production, Environment in which the software is considered to released into the world and available to end users; i.e. production.  The software is considered to be functionally complete and has passed all necessary testing before being deployed into this environment.

### Project

Within the context of el-CICD, a Project is a collection of one or more Git repositories, and each repository typically represents a single component of the application.  Components can represent libraries, microservices, or monolithic applications.

### Build Once, Deploy Many

Modern software development with images and containers works under the principle that software should be built only once, and then be able to be deployed to every environment through production.  While it does not and cannot ensure uniformity in every environment, following this principle can guarantee to the highest degree possible functional uniformity across environments, and mostly eliminate the possibility that an error found in one environment will not be reproducible in another; i.e. the “works on my machine” quality assurance problem in which a bug found in a downstream environment is unable to to predictably and reliably be reproduced in an earlier environment given the same [Code Base](#code-base) is greatly mitigated.

### Continuous Integration

Continuous Integration (CI) is the principle of building source code as soon as it is delivered.  This includes compiling, testing, scanning, assembling, and deploying the artifacts produced from the source code.  Ideally source code is delivered often and in small amounts.  This usually means the delivery granularity is per feature or change worked on by a developer.  Source code is considered delivered if it is pushed to the branch of the SCM holds the code that builds the images that are eventually pushed to production; i.e. the [Development Branch](#development-branch)

There are many issues to take into account when implementing CI, but they can mostly fall under the following concerns of approved Code Bases, The Build, and standardization of processes and practices.

#### Development Branch

The Development Branch is the integration branch for features.  Features are typically worked on separate branches, and when completed are merged to the Development Branch in a repository.  When the software is released, the Development Branch is typically merged into the Master Branch.  While outside the scope of this document, because el-CICD does not concern itself an organizations overall branch management procedures, more can be read about [GitFlow here](http://datasift.github.io/gitflow/IntroducingGitFlow.html).

#### Code Base

Each Project will be developed using one or more programming languages and/or platforms, such as Java, JavaScript, or Python, and optionally a particular framework or frameworks supported by that language such Spring Boot, Angular, or Django, respectively.  There are also different testing frameworks within each language or platform; e.g. JUnit, Mocha, or pytest.  Organizations should work with their development teams to identify a set number of languages, platforms, and frameworks to support.  While different Code Bases are better at solving different problems than the other, each Code Base an organization approves for their development teams to develop with increases the complexity of the CICD system, and can make it harder for resources to be portable across Projects either in support or development roles.

#### The Build

The Build is an overloaded term, and in CI is we use it colloquially.  It is actually comprised of five steps: compiling, testing, scanning, assembly, and eventually a successful deployment.  If any of these steps fail, the Project should be considered to be in a bad state, and all efforts should be directed at fixing it immediately.  If a team is following modern software development best practices, it is reasonable for a team to expect that the source is never, or at least extremely rarely, in a bad state; i.e. for every source code delivery

* All code compiles successfully
* All tests run and pass
* Security scans and linting find no problems
* Artifacts produced during compilation are successfully assembled into a deployable package
* The software successfully deploys

##### Build

If a Project has a Code Base that needs to be compiled then the CICD system should execute this step.  Not all Code Bases will require this step; e.g. Python or PHP.  As a counter-example, Java is packaged into \*.jar or \*.war files after compilation.  If the code fails to compile, The Build is considered to have failed.

##### Test

Best practices dictates all Projects should implement unit and integration tests, and the CICD system will execute them all for each build.  If any test fails, The Build is considered to have failed.

##### Scan

Code should be scanned and/or linted to ensure coding standards are being followed, for coverage metrics of the tests, for possible security vulnerabilities and exposures, etc.  Ideally The Build should fail if any of these metrics fail to meet organizational standards, but in practice it takes a disciplined and mature organization and team to implement this.  Many organizations and/or teams instead take the issues discovered here, prioritize them, and feed them back into the Project plan to be dealt with later.  Issues fed back into the Project for later work can sometimes be referred to as _technical debt_.

##### Assemble

This step is for any further packaging or work needed by The Build.  It could mean as little as cleaning any unneeded artifacts left over from the previous steps to further packaging of the artifacts already created that didn't fit under the compile step.

##### Deploy

Successfully push library artifacts to the [Artifact Repository](#artifact-repository).  This typically means uploading artifacts such Java jars or Python pip wheels, which are then made available to be used by one or more microservices.

#### Standardization

In order that The Build can be easily supported and executed by a CI system, an organization should work with the development teams within the context of each Code Base to standardize as much as possible all aspects of The Build.  This includes the tools used, the directory structure of Project repositories, coding standards, etc.

A real world example of this might be requiring all Java development teams to use Apache Maven to define their builds.  The build step might then call

```bash
# settings.xml can hold build secrets and be mounted in a Jenkins build agent
mvn -s /path/to/settings.xml -DskipTests --batch-mode clean package`
```

This enables the team supporting the CICD system to confidently know they can complete a build for any Java Project using Maven without having to understand the individual details of any individual Project.  Developers in turn never have to worry about their Projects being incompatible with the CICD system, and don't have to think about reinventing the wheel for each new Project.

Another example would be standardizing on the unit test tools used.  While Apache Maven would somwhat mitigate the need for the CI system to know which test tools were used by the developers for their unit tests, there are many platforms which don’t have a standard build tool for the CI tool to leverage.  There is also the issue of resource portability between teams to consider.

### Continuous Delivery

Continuous Delivery (CD) is where the source code is always in a state where the artifacts produced by CI are deployable.  CICD systems almost without exception use automated deployment to a [Dev Environment](#dev-environment) after the CI process has completed to verify the software as built is indeed deployable, thus demonstrating the minimum requirements of CICD have been met.

In a CD system, initiating subsequent deployments to downstream environments are strictly manual; i.e. after the automated deployment to Dev, all downstream environments through Prod are initiated and approved through direct human intervention.  The idea behind this is that while the software **can** be delivered, it might not be **ready** to be delivered.  Perhaps the software hasn’t cleared QA to be passed to UAT, or perhaps the operations team only wants to perform performance testing after the UAT team has signed off on the final implementation.  Perhaps the software is still missing some relevant features that make deploying the code at that time less than optimal.

After a  responsible resource has given their final approval for promotion to the next environment, deployment is fully automated.  The deployment configuration should be defined by artifacts versioned and pulled from an SCM, and then applied during deployment.

In summary, Continuous Delivery recognizes that automated testing can and should be used to increase productivity and reduce the time to promotion to downstream environments, but it also recognizes that no amount of automated testing can capture all functional and business requirements to make automated promotion to downstream environments desirable.

### Continuous Deployment

Continuous Deployment, also confusingly known as CD, is the practice of automating promotions through some or all environments including through production.  In order to implement this type of system, it first requires a very mature team with excellent automated testing coverage and writing capabilities.  Very few teams are able to meet that standard.  It also requires a Project in which it is possible for automated testing to fully cover all the requirements of the Project.  Projects requiring user acceptance testing do not meet this requirement, for example.

el-CICD does not address this issue, and is not designed with this functionality in mind now or for the future considering the very high bar and unique circumstances that must be met for a Project to support it.  This topic is only presented for completeness and acknowledging the confusion that sometimes arises between Continuous Delivery and Continuous Deployment.

Note that the automated building and deployment to Dev is not to be considered an example of Continuous Deployment.  Code must be manually merged into the Development Branch to trigger The Build, and best practices requires that developers work on features in separate feature branches before manually merging, and thus triggering The Build.

## Tools

There are a number of tools that are needed for an automated CICD system.  They are summarized below.  All of these tools are external to el-CICD, but are necessary for el-CICD to function.

### Project Definition Repository

The Project Definition Repository should contain enough information about each Project in the organization to automate the creation of its supporting pipelines, drive the pipelines, and define the environments required for each Project in the organization.

### Source Control Management (SCM)

A SCM hosts Source Code Repositories, and serves the purpose of tracking the source code files and documents of a Project.  It is used to perform versioning, branching, and tagging.

### Scanner

The scanner consists of one or more tools, and is responsible for scanning source code and any of its dependencies for adherence to standards, code coverage metrics, and/or security vulnerabilities and exposures.

### Artifact Repository

The purpose of the Artifact Repository is to store artifacts produced by a CI process.  Modern builds generally result in two different types of artifacts, either libraries for reuse or in images meant to be deployed into an environment.

How these artifacts are hosted depends on how they are meant to be consumed.  For example, a Java jar file meant to only be used as a dependency for another microservice might be stored within a Maven repository, RPM’s intended to be installed into a Docker image in an RPM repository, and a Docker image to be deployed or used as a base image in a Docker repository.  Modern artifact repositories generally support many types of standards depending on the need.

For the purposes of the this document, _Image Repository_ can be read as a synonym to the Artifact Repository.

### Automation Server

The Automation Server is the heart of a CICD system, and its job is to run any and all CICD scripts, or [_pipelines_](#pipeline), a number of which should fully implement the CICD process from the time source code is delivered through deployment to Prod.

#### Pipeline

A script run on an Automation Server to build and/or deploy Project artifacts.  In OKD, pipelines are defined using OKD's [BuildConfigs](https://docs.okd.io/latest/builds/understanding-buildconfigs.html).

### Container Orchestration Platform

The Container Orchestration Platform is the newest type of tool available for use by organizations.  While software can run directly on bare metal or in virtual machines, many if not most applications designed today are built as images.  This means they are built as Open Container Initiative (OCI) or Docker images, and a container is a deployed and running image.

Modern application architectures favor a microservice architecture approach, in which many images are designed and implemented to be small, targeted pieces of software running next to and with each other to form a larger application as a whole, rather than as a more monolithic application made up of a smaller number of larger, multipurpose components.  This level of complexity requires a platform to support the deployment, organization, orchestration, and running of groups of images, which may represent one or more applications.  This is the responsibility of a Container Orchestration Platform.

#### Namespaces

Namespaces act as a virtual Container Orchestration Platform, allowing the running containers acting as an application to appear to operate in virtual isolation.  This concept will be leveraged to represent environments.

[**NOTE**: Kubernetes initiated the concept of namespaces in the container orchestration space, and OKD extended that concept and refers to them as _Projects_.  This can be confusing at times when referring to a Project in el-CICD or in OKD, so el-CICD uses the namespace monicker whenever possible.]

### Secret Encryption Tool

Runtime software often contains secrets such as passwords or access tokens to enable secure access to other systems.  None of the aforementioned systems currently offer a manner of safely storing these secrets for purposes of versioning in the SCM for fully automated deployments.

Without a way to encrypt secrets so they can be safely stored in the SCM for later decryption in the Container Orchestration Platform, secrets would need to be maintained and deployed by hand.  The Secret Encryption tool adds extra functionality to the Container Orchestration Platform so that secrets can be safely encrypted and stored with the rest of the source code for fully automated deployments.

## CICD Development Workflow Patterns

CICD systems encompass a number of workflow patterns to support development.  Ultimately these will be expressed as pipelines.  The patterns expressed below are described in the context of the concepts and tools defined above.

### Build-library

This workflow will pull source from the SCM, build it if necessary, run all unit and integration tests, scan the code, package the artifacts, and push the relevant artifacts to the Artifact Repository for use by other components within or external to the software Project.  el-CICD supports two states:

* **SNAPSHOT**
* **RELEASE**

el-CICD only supports these concepts in general; i.e. a snapshot library build is simply a library build that is not a release.  It is up to the organization to define what this means, and up to organizations and Project teams to decide which to use and when.  el-CICD does not define or manage the promotion of libraries from one state to the other.

### Build-to-Dev

The initial CICD process.  This workflow will pull source from the SCM, build it if necessary, run all unit and integration tests, scan the code, package the artifacts, create an image, push the image to the Image Repository, and then attempt to deploy the image from the Image Repository to the Container Orchestration Platform.

### Promotion

This workflow implements the process of image promotion and deployment from one non-production environment to the next, always starting from Dev; e.g. from Dev to QA, or QA to UAT.  Promotion will always follow a predefined, linear path.  [Deployment Patching](#deployment-patching) and [Deployment Branching](#deployment-branch) are two new concepts unique to el-CICD to support the Promotion workflow.

#### Deployment Branch

Images by definition are an immutable binaries and stored in the Image Repository, but the deployment configuration is mutable source code and stored in the SCM.  As an image is promoted from one SDLC environment to the next, the Development Branch from which the image was built will continue to change, and potentially and eventually become out of sync with the deployment configuration for an image built on a previous commit to the SCM.  The problem arises as to how to continue to version the and sync the deployment configuration with image, while not impeding development of the source code that built the image?

To solve this dichotomy, the concept of a _Deployment Branch_ was created.  A Deployment Branch is a branch created at the source commit from which an image was built, and it's purpose is to track any changes to the deployment configuration of the image while keeping it associated with the image's original source code.  This branch enables users to track and version changes to the deployment of one image without holding back continuing development of the original source code.

#### Deployment Patching

In practical terms, _Deployment Patching_ refers to the process of modifying the deployment resources of an image on a [Deployment Branch](#deployment-branch). This keeps deployment resources in sync with the code that created the image, allows the deployment resources of the image to be versioned, and doesn't interfere with ongoing development on the Development Branch.

### Component Rollback and Roll-Forward

Component, or microservice, rollback and roll-forward is the ability to deploy different versions of the same microservice within the same environment.  Whether rolling back to an earlier version, or forward again to a later version that has already been deployed in the environment, the process must not only pull the correct build of the image, but also find the version’s latest deployment configuration in the SCM.  This requires coordination between the Image Repository and SCM for successful and repeatable deployments when rolling back and/or forward.

This workflow does not apply to Dev, since that environment will always represent the latest state of the SCM.  This workflow also does not apply to [Prod](#deploy-to-production) since that environment only deploys versions of complete applications comprised of one or more components or microservices, and not individual images.

This workflow also does not apply to different deployment configurations of the same image.  Those are stored in the Deployment Branch, and would require a new commit with whatever configuration you wish to deploy an image.

### Deploy To Production

Deployment to Prod is a more complex workflow that actually encompasses a number of distinct workflows.

#### Application, or Project, Releases

Up to this point, each environment considered the deployment of an microservice repository as an independent event.  There was no consideration by the CICD system as to the interdependence within the environment that might exist between components or microservices that are built and/or deployed separately from one another, other than they were all defined as belonging to the same Project.

When releasing into production, on the other hand, final approval for release to production assumes that the release was tested with a particular version of each component.  If there's ever to be a concept of rolling back or rolling forward to a known, good state of the application, this can only be done if the total set of components or microservices is treated as a single unit.

#### Pre-prod

_Pre-prod_ is defined as the penultimate environment before Prod, and its purpose is two-fold.  First, it should be the place to test a production deployment before actually deploying into Prod.  Second, it's the place where [Release Candidates](#release-candidate) are defined.  To illustrate, if the environments for a CICD process are Dev -> QA -> Stg -> Prod, then Stg is considered Pre-prod, and only images deployed in Stg will be considered for possible inclusion in a Release Candidate.

#### Release Candidate

Creating a Release Candidate is the first step in defining a release of an Application.  _Release Candidates_ are a collection of microservices deployed in Pre-prod and identified as a whole for _potential_ deployment to Prod.  Not every image deployed to Pre-prod must be part of the Release Candidate, but any image not deployed to Pre-prod cannot be part of the Release Candidate.  The Release Candidate is not considered an official release until it is approved and deployed to production.  The collection of microservices is defined in the workflow by tagging all selected, deployed images in Pre-prod and their associated deployment configuration source commits with a version number or label; e.g. 1.0.0 or 1.1.0a.

#### Deploy-to-Prod

When the final decision has been made that a Release Candidate should be deployed into production, the actual Deploy-to-Prod workflow can be triggered.  Along with the actual deployment of images into the production environment, this process will re-tag all the Release Candidate's images in the Image Repository and branch associated deployment configuration source commits in the SCM at the point of the Release Candidate tag.

##### Release Version

The collection of images and branches tagged and created by the Deploy-to-Prod process are collectively known as a _Release Version_.  These are used to deploy and redeploy a particular version of the application into production.

###### Release Region

Applications are sometimes deployed to production on more then one cluster.  This could be for high availability, support for different regions, or A/B testing or blue/green deployment scenarios.  Regardless of the reason, these deployments may have different configurations, and thus they need to be able to be differentiated from eachother.  el-CICD uses the concept of a Release Region to enable these types of deployments.

##### Production Rollback/Forward/Deployment Patching

Because production deployments of applications are treated as a whole rather than any one of its parts, this workflow is also handled by the Deploy-to-Prod workflow.  When rolling an application back or forward, a user is really just deploying a particular Release Version of the application with its latest matching deployment configuration(s).  Similarly, [Deployment Patching](#deployment-patching) of a Release Version is treated as a redeployment of the same version of the application with the updated deployment configuration information pulled from the SCM; i.e. each microservice whose deployment configuration has been changed is rolled out again as a group.

#### Hotfixing

No matter how good the planning or testing, sometimes bugs or other emergencies make waiting for the next application release untenable, rollback is not an option, and changes to the application currently deployed in production need to be made as soon as possible.  Colloquially, this is known as a _Hotfix_.

Changes to the code are typically made on a Hotfix Branch rather than on the Development Branch, merged into a new release, and the new release is deployed.  Ideally, this process should have little to no impact on the next release of the application, and the changes made for the Hotfix will potentially be merged into the current release's Development Branch.

## Supporting Projects

A number of other OSS products are used to support the system, and it should go without saying we are extremely grateful for the work each of their development teams do.

### Git

[Git](https://git-scm.com/) is the SCM used by el-CICD.  No others are currently supported.

### GitHub

[GitHub](https://github.com) is a third party application for hosting Git repositories, and [github.org](github.org) is where el-CICD is currently hosted.   This Project was developed using GitHub, and it is currently the only Git repository hosting application supported by el-CICD.

**NOTE**: The el-CICD project considers it a priority to support other Git repository hosting sites, and it is currently a top priority on our TODO list.

### Jenkins

[Jenkins](https://www.jenkins.io/) is an open source software (OSS) Automation Server, and used for defining and running the pipelines to build and deploy microservices onto OKD.

### skopeo

[`skopeo`](https://github.com/containers/skopeo) is a command line utility for the copying, tagging, deleting, and inspection of images on OCI and Docker v2 compliant Image Repositories.

### DockerHub

Any online or or on premise Image Repository that is compatible with `skopeo` or `Docker` is compatible for use with el-CICD.  The examples in the accompanying tutorial use [DockerHub](https://hub.docker.com), but [Quay](https://quay.io), [Artifactory](https://jfrog.com/artifactory/) or any other OCI compliant Image Repository could also have been used.

### OKD

[OKD](https://okd.io) (and it's downstream project [OpenShift](https://www.openshift.com/)) is OSS from Red Hat that acts as the Container Orchestration Platform, and in whole is a Platform as a Service (PaaS).  While Jenkins runs and defines the pipelines and is the heart of el-CICD, it is OKD that is the body that will ultimately host and coordinate with Jenkins to run them.  el-CICD runs equally will on versions 3.11 and 4.x+, with only minor configuration changes.

### Kustomize

OKD has a [Template](https://docs.okd.io/latest/openshift_images/using-templates.html) resource, which provides some use towards defining classes of resources that are configurable via scripts.  [`Kustomize`](kustomize.io) is a tool (also built into the latest `oc` CLI) that makes it easy to patch OKD resources, and OKD Templates in particular, for even greater reuse across and within each environment.

### SealedSecrets

[SealedSecrets](https://github.com/bitnami-labs/sealed-secrets) is an OSS tool providing a mechanism for encrypting secrets for external versioning and automation purposes.