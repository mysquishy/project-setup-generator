# Project Setup Generator Documentation

## Overview

The Project Setup Generator is a tool designed to create customized setup scripts for any type of software project. Rather than manually creating project structures and organization scripts for each new project, this meta-script generates tailored setup scripts based on a defined project structure.

## Key Features

- **Automatic Structure Detection**: Parses project structure from JSON or text definition files
- **Technology-aware Organization**: Detects primary language and adjusts file organization accordingly
- **Git Integration**: Sets up Git repository with proper branches, commit templates, and hooks
- **File Organization**: Automatically organizes files from a downloads folder into the proper project structure
- **Documentation Generation**: Creates README and other documentation files based on project information

## Requirements

- Bash shell environment (Linux, macOS, or WSL on Windows)
- The following utilities:
  - `jq` (for JSON processing)
  - `grep`, `sed`, `awk` (for text processing)
  - `git` (for repository setup)

## Installation

1. Download the `project-setup-generator.sh` script
2. Make it executable:
   ```bash
   chmod +x project-setup-generator.sh
   ```
3. Run the script:
   ```bash
   ./project-setup-generator.sh
   ```

## Usage Workflow

### 1. Prepare Project Structure Definition

Create one of the following files in your source/downloads directory:

- **JSON Structure Definition** (`project-structure.json`):
  ```json
  {
    "name": "root",
    "type": "directory",
    "children": [
      {
        "name": "src",
        "type": "directory",
        "children": [
          {
            "name": "main.js",
            "type": "file"
          },
          {
            "name": "utils",
            "type": "directory",
            "children": [
              {
                "name": "helpers.js",
                "type": "file"
              }
            ]
          }
        ]
      },
      {
        "name": "docs",
        "type": "directory",
        "children": [
          {
            "name": "README.md",
            "type": "file"
          }
        ]
      }
    ]
  }
  ```

- **Text Structure Definition** (`project-structure.txt`):
  ```
  # Project Structure Definition
  # Format: Use indentation to indicate hierarchy
  # Lines starting with # are comments and will be ignored
  # Add [file] marker for files, directories are assumed by default

  root/
    src/
      main.js [file]
      utils/
        helpers.js [file]
    docs/
      README.md [file]
  ```

### 2. Run the Script

Execute the Project Setup Generator script:

```bash
./project-setup-generator.sh
```

### 3. Input Project Information

The script will prompt you for:
- Project name
- Project description
- Author name
- Project version

### 4. Specify Source Path

Provide the path to the folder containing:
- Downloaded project files (if any)
- Structure definition file (project-structure.json or project-structure.txt)

### 5. Review Detected Settings

The script will:
- Parse your structure definition
- Detect the primary programming language
- List detected files and directories

### 6. Generate Setup Script

The script creates a custom setup script in your source folder with the filename:
```
[project-name]-setup.sh
```

### 7. Run the Generated Setup Script

Execute the generated setup script to create your project:
```bash
bash ./[project-name]-setup.sh
```

## Structure Definition Formats

### JSON Format

The JSON format uses a nested object structure:
- Each node has a `name` and `type` property
- `type` can be either "directory" or "file"
- Directories have a `children` array containing their contents

Example:
```json
{
  "name": "root",
  "type": "directory", 
  "children": [
    {
      "name": "src",
      "type": "directory",
      "children": [...]
    }
  ]
}
```

### Text Format

The text format uses indentation to show hierarchy:
- Each line represents a directory or file
- Directories end with a slash (/)
- Files are marked with `[file]` at the end of the line
- Indentation (spaces or tabs) indicates parent-child relationships
- Lines starting with # are treated as comments

Example:
```
root/
  src/
    index.js [file]
  tests/
    test-utils.js [file]
```

## Features of Generated Setup Scripts

The generated setup scripts include:

1. **Project Structure Creation**
   - Creates all defined directories
   - Creates placeholder files in appropriate locations

2. **File Organization**
   - Moves files from a downloads folder into the project structure
   - Uses smart detection to place files in appropriate directories
   - Creates a log of all file movements

3. **Git Repository Setup**
   - Initializes Git repository
   - Creates main and develop branches
   - Adds appropriate .gitignore file based on project type
   - Sets up commit message templates
   - Configures Git hooks for quality checks

4. **Documentation Generation**
   - Creates README.md with project information
   - Documents project structure
   - Includes setup and usage instructions

5. **Interactive Menu System**
   - Provides a user-friendly menu for all operations
   - Allows selective use of features

## Language-Specific Features

The generated setup scripts include specialized behavior for:

- **JavaScript/TypeScript**
  - Recognizes package.json, config files
  - Organizes components, tests, and utilities

- **Python**
  - Handles requirements.txt and setup.py
  - Creates __init__.py files in module directories
  - Recognizes test files (test_*.py or *_test.py)

- **Java**
  - Supports both Maven and Gradle projects
  - Organizes source and test directories

- **Go**
  - Sets up proper Go module structure
  - Creates appropriate .gitignore entries

- **PHP**
  - Supports Composer-based projects
  - Organizes vendor dependencies

- **Ruby**
  - Handles Gemfile-based projects
  - Sets up appropriate directory structure

## Customization

You can customize the generated setup script after creation by:

1. Adding custom hooks to the Git configuration
2. Modifying file organization rules
3. Adding language-specific setup steps
4. Extending the menu with additional options

## Troubleshooting

**Issue**: Script fails with "command not found" errors
- **Solution**: Ensure all dependencies are installed (jq, grep, sed, awk)

**Issue**: Structure file not detected
- **Solution**: Ensure the file is named exactly "project-structure.json" or "project-structure.txt"

**Issue**: Files not organized correctly
- **Solution**: Check file extensions and naming patterns match the script's expectations

**Issue**: Git repository not initializing properly
- **Solution**: Ensure git is installed and properly configured

## Examples

### Simple Web Project

Structure definition:
```
root/
  index.html [file]
  css/
    style.css [file]
  js/
    main.js [file]
  images/
```

### Node.js API Project

Structure definition:
```
root/
  src/
    index.js [file]
    routes/
      api.js [file]
    controllers/
    models/
  tests/
  config/
    default.json [file]
  package.json [file]
  README.md [file]
```

## Best Practices

1. **Be Specific**: Define your structure in as much detail as possible
2. **Use Consistent Naming**: Follow naming conventions for your project type
3. **Include All Key Files**: Don't forget configuration files like .gitignore
4. **Test First**: Run the generator with a minimal structure first to verify
5. **Version Control**: Keep your structure definitions under version control

## License

This project is open source and available under the MIT License.
