# Project Setup Generator

A meta-script that generates customized project setup scripts based on predefined structure definitions. This tool helps standardize project initialization across different types of software projects.

## Overview

The Project Setup Generator is designed to solve the common problem of repetitively setting up new project structures and organization scripts. Rather than manually creating folders and files for each new project, this tool:

1. Takes a project structure definition (in JSON or text format)
2. Automatically detects the likely programming language and project type
3. Generates a custom setup script that:
   - Creates the defined folder structure
   - Organizes files from a downloads folder
   - Sets up Git with proper branching, commit templates, and hooks
   - Generates appropriate documentation

## Features

- **Flexible Structure Definition**: Define your project structure in either JSON or text format
- **Smart Technology Detection**: Automatically detects primary language and project type
- **File Organization**: Intelligently sorts files into the appropriate project folders
- **Git Integration**: Sets up Git repository with proper branches and commit conventions
- **Documentation Generation**: Creates README.md and other documentation files
- **Cross-Platform**: Works on Linux, macOS, and Windows (via WSL)

## Requirements

- Bash shell environment
- Core utilities: `jq`, `grep`, `sed`, `awk`
- Git (for repository setup features)

## Installation

```bash
# Clone the repository
git clone https://github.com/mysquishy/project-setup-generator.git

# Make the script executable
cd project-setup-generator
chmod +x project-setup-generator.sh
```

## Quick Start

1. **Create a structure definition file** in either text or JSON format:

   **Text format** (project-structure.txt):
   ```
   # Project Structure Definition
   root/
     src/
       main.js [file]
       utils/
         helpers.js [file]
     docs/
       README.md [file]
   ```

   **JSON format** (project-structure.json):
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

2. **Run the generator script**:
   ```bash
   ./project-setup-generator.sh
   ```

3. **Follow the prompts** to input project information and source folder path.

4. **Run the generated setup script** to create your project:
   ```bash
   ./my-project-setup.sh
   ```

## Detailed Usage

### Step 1: Prepare Your Source Folder

Create a folder to store your project files and structure definition:

```bash
mkdir -p ~/project-downloads
cd ~/project-downloads
```

Place your structure definition file here (either `project-structure.txt` or `project-structure.json`).

### Step 2: Run the Generator

```bash
/path/to/project-setup-generator.sh
```

The script will prompt you for:
- Project name
- Project description
- Author name
- Project version
- Path to the source folder

### Step 3: Generated Setup Script

The generator produces a script named after your project (e.g., `my-project-setup.sh`). This script provides:

- A menu-driven interface for project setup
- Options for creating the structure, organizing files, and setting up Git
- Documentation generation

## Examples

Check out the [`examples/`](./examples/) directory for sample structure definitions:
- [Web Application](./examples/web-app/project-structure.txt)
- [Node.js API](./examples/node-api/project-structure.json)

## Structure Definition Formats

### Text Format

The text format uses indentation to show hierarchy:
- Each line represents a directory or file
- Directories end with a slash (/)
- Files are marked with `[file]` at the end of the line
- Indentation indicates parent-child relationships
- Lines starting with # are treated as comments

Example:
```
root/
  src/
    index.js [file]
  tests/
    test-utils.js [file]
```

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

## Advanced Features

The generated setup scripts include:

- **Project Structure Creation**: Creates all directories and placeholder files
- **File Organization**: Organizes files from downloads folder into the project structure
- **Git Repository Setup**: Initializes with main and develop branches, .gitignore, etc.
- **Git Commit Templates**: Enforces conventional commit message format
- **Git Hooks**: Pre-commit hooks for code quality checks
- **README Generation**: Creates comprehensive project documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by common patterns in development workflow automation
- Designed to standardize project setup across different project types
