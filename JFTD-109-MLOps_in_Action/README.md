# Fine-Tuning a Qwen 1.5 Model and Logging to a Model Registry

## Overview

This notebook demonstrates the process of fine-tuning a small-scale Qwen model (Qwen/Qwen1.5-0.5B-Chat) on a public instruction-based dataset. We will use Parameter-Efficient Fine-Tuning (PEFT) with LoRA to make the process memory-efficient.

### Features

Key Steps:

- **Setup**: Install required libraries and import necessary modules.
- **Configuration**: Define all parameters for the model, dataset, and training.
- **Data Preparation**: Load and prepare the dataset for instruction fine-tuning.
- **Model Loading and Fine-Tuning**: Load the pre-trained model and tokenizer, and then fine-tune it using trl's SFTTrainer.
- **Evaluation**: Compare the performance of the base model with the fine-tuned model.
- **Model Logging**: Log the fine-tuned model and its metrics to a model registry.
