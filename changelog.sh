#!/bin/bash

# Check if the llm command is available, if not, install it
if ! command -v llm &> /dev/null; then
    read -p "llm command not found, do you want me to install it for you (pip install llm)? (yes/no): " response
    if [[ "$response" == "yes" ]]; then
        echo "running pip install llm..."
        pip install llm
        llm install llm-ollama
    else
        echo "llm command is required. Exiting..."
        exit 1
    fi
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not a git repository"
    exit 1
fi

# Check if we have the required arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tag1> <tag2>"
    echo "Example: $0 v1.0.0 v1.1.0"
    exit 1
fi

TAG1="$1"
TAG2="$2"

# Verify that both tags exist
if ! git rev-parse "$TAG1" >/dev/null 2>&1; then
    echo "Error: Tag '$TAG1' does not exist"
    exit 1
fi

if ! git rev-parse "$TAG2" >/dev/null 2>&1; then
    echo "Error: Tag '$TAG2' does not exist"
    exit 1
fi

# Get the commit log between the two tags, excluding merge commits and pagination
COMMIT_LOG=$(git --no-pager log "$TAG1".."$TAG2" --oneline --no-merges)

# Prepare the prompt in Portuguese for the LLM
PROMPT="Dados os seguintes commits do git, gere um changelog bem formatado para a versão $TAG2.
Agrupe as mudanças em categorias como 'Recursos', 'Correções de Bugs', 'Melhorias de Performance', etc. Não duplique commits em categorias diferentes.
Formate a saída em markdown.

Mensagens de commit:

$COMMIT_LOG"

# Check if the -d flag is passed
if [ "$#" -lt 2 ]; then
    echo "Prompt:"
    echo "$PROMPT"
fi

# Create changelog directory if it doesn't exist
CHANGELOG_DIR="changelog"
mkdir -p "$CHANGELOG_DIR"

# List available models and prompt the user to select one
echo "Listing available models..."
if ! ollama list &> /dev/null; then
    echo "Server ollama provavelmente não está rodando. Inicie com o comando ollama serve"
    exit 1
fi
ollama list

echo "Please type the selected model name:"
read -p "Model: " MODEL

# Verify that the selected model is valid
if ! ollama list | grep -q "$MODEL"; then
    echo "Erro: Model '$MODEL' not found"
    exit 1
fi

echo "Generating changelog for $TAG2 with model $MODEL..."

# Use datasette-llm to generate the changelog and save it in the changelog directory
CHANGELOG_FILE="$CHANGELOG_DIR/CHANGELOG_$TAG2.md"
llm -m $MODEL "$PROMPT" > "$CHANGELOG_FILE"

echo "Changelog generated and saved in $CHANGELOG_FILE"

# Display the generated changelog
cat "$CHANGELOG_FILE"
