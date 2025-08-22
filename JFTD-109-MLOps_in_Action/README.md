# Introduction

This file contains the assets we use for the SwampUp2025 course entitled, "JFTD - 109 - MLOps in Action"

### Features

- **Secure Storage**: Protect your proprietary information by deploying models and additional resources to Artifactory local repositories, giving you fine-grain control of the access to your models.

- **Easy Collaboration**: Share and manage your machine learning projects with your team efficiently.

- **Easy Version Control**: The Machine Learning Repositories SDK (FrogML) provides a user-friendly system to track changes to your projects. You can name, categorize (using namespaces), and keep track of different versions of your work.

## How to Test Locally

1. **Clone the Repository**: Clone this GitHub repository to your local machine.

2. **Make sure that you have your evironment set up**: It should be usign Python 3.10.17

3. **Install and Configure the FrogML SDK**: Use your account [JFrog ML API Key](https://docs.qwak.com/docs/getting-started#configuring-qwak-sdk)to set up your SDK locally.

    ```bash
    pip install frogml
    pip install frogml-cli
    frogml configure --url https://jfrogmldemo.jfrog.io/ --type jfrog  --token <JFrog Acess Token>
    ```

4. **Run the Model Locally**: Execute the following command to test the model locally:

    ```bash
    frogml models build . --model-id llm_blm --main-dir main --memory "60GB"  --gpu-compatible
    ```
