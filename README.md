# llm-changelog

Use LLMs to generate changelogs for your git repo.

It feeds your git log commit messages between two different tags to the LLM and generate a change log.

## Dependencies

* Ollama: https://ollama.com
* LLM CLI https://llm.datasette.io/en/stable/

## Setup

Install [Ollama](https://ollama.com/download).

On MacOS, you can `brew install ollama`

## How to run

Copy the `changelog.sh` script to your git repo and run it:

```
chmod +x changelog.sh
```

```
./changeloh.sh 1.0.0 1.1.0
```
