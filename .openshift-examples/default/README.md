# Statically Defined Openshift Resources

The CICD Pipeline system will process any static OpenShift resource files in the `default` or specific environemnt directories when deploying to any environment.  You may override a resource in a specific, or even "remove" it (i.e. provide an empty file with the same name), by giving a file in an environment directory the same name.

The system will accept the following file extensions:

* .json
* .yaml
* .yml

The name of the files are not relevent to the CICD process, and thus can be named anything that makes sense to the developers.

## Labelling of Resources

All statically defined resources will be automatically labeled by the CICD process to match the generated resources from template.  The following labels will be applied:
labels:

* **deployment-branch**: The Deployment Branch; e.g. `deployment-qa-e62f621`
* **deployment-commit-hash**: The commit hash on the deployment branch used to create the resources to deploy the microservice; e.g. `e62f621`
* **git-repo**: The Git Repo the microservice and resources were built from; e.g. `Test-CICD1`
* **microservice**: The microservice name; e.g. `test-cicd1`
* **projectid**: The Project ID; e.g. `test-cicd`
* **release-version**: The Release Version; e.g. `undefined` or `1.0`
* **src-commit-hash**: The commit hash on the Development Branch the original image was built from; e.g. `e62f621`

These labels MUST remain for the CICD process to manage the application correctly.

**Removal will cause inconsistent or broken builds and deployments.**

## Sealed Secrets

If you do want to leverage static resource files from the default folder, do **NOT** include the namespace key in the file.  The system will inject this as part of the CICD process.

In the case of a Sealed Secret you wish used across all environments in Dev and Test environments, you may set the scope to `cluster-wide`.  **Do NOT use cluster-wide scope for Sealed Secrets in Prod environments.**

