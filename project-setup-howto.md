# How to Use the Project Setup Generator

This guide provides step-by-step instructions for using the Project Setup Generator to create customized project setup scripts for your software projects.

## Quick Start

1. **Download the Generator Script**
   Save the `project-setup-generator.sh` script to your computer.

2. **Make the Script Executable**
   ```bash
   chmod +x project-setup-generator.sh
   ```

3. **Prepare Your Project Structure**
   Create a `project-structure.txt` or `project-structure.json` file describing your project.

4. **Run the Generator**
   ```bash
   ./project-setup-generator.sh
   ```

5. **Run the Generated Setup Script**
   ```bash
   ./your-project-name-setup.sh
   ```

## Detailed Instructions

### Step 1: Prepare Your Environment

Make sure you have the required dependencies installed:

```bash
# For Debian/Ubuntu
sudo apt update
sudo apt install jq git grep sed awk

# For macOS (using Homebrew)
brew install jq git

# For Red Hat/Fedora
sudo dnf install jq git grep sed awk
```

### Step 2: Prepare Your Downloads Folder

Create a folder to contain your project downloads and structure definition:

```bash
mkdir -p ~/project-downloads
cd ~/project-downloads
```

### Step 3: Create a Project Structure Definition

You can define your project structure in either JSON or text format:

#### Option A: Text Format (Recommended for Simplicity)

Create a file named `project-structure.txt`:

```bash
nano project-structure.txt
```

Add your structure using this format:

```
# My Project Structure
root/
  src/
    main.js [file]
    components/
      header.js [file]
      footer.js [file]
  styles/
    main.css [file]
  docs/
    README.md [file]
```

#### Option B: JSON Format (Recommended for Complex Structures)

Create a file named `project-structure.json`:

```bash
nano project-structure.json
```

Add your structure using this format:

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
          "name": "components",
          "type": "directory",
          "children": [
            {
              "name": "header.js",
              "type": "file"
            },
            {
              "name": "footer.js",
              "type": "file"
            }
          ]
        }
      ]
    },
    {
      "name": "styles",
      "type": "directory",
      "children": [
        {
          "name": "main.css",
          "type": "file"
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

### Step 4: Download Project Files (Optional)

If you have existing files to include in your project, place them in the same folder as your structure definition.

### Step 5: Run the Project Setup Generator

Navigate to where you saved the generator script and run it:

```bash
cd /path/to/script
./project-setup-generator.sh
```

You'll be prompted to provide:
- Project name
- Project description
- Author name
- Project version
- Path to your downloads folder (containing the structure definition)

### Step 6: Review and Confirm

The script will:
1. Parse your structure definition
2. Detect the primary programming language
3. Show the directories and files it found
4. Generate a setup script

### Step 7: Run the Generated Setup Script

The generator creates a setup script named after your project. Run it:

```bash
bash /path/to/downloads/your-project-name-setup.sh
```

### Step 8: Follow the Setup Script Menu

The generated setup script provides an interactive menu with the following options:

1. **Create/rebuild project structure**
   - Creates folders and files according to your definition

2. **Organize files from downloads directory**
   - Moves files from downloads to the appropriate project folders

3. **Setup Git repository**
   - Initializes Git with main and develop branches

4. **Create Git commit templates**
   - Sets up standardized commit message templates

5. **Setup Git hooks**
   - Configures pre-commit and commit-message checks

6. **Generate README.md**
   - Creates a comprehensive README for your project

7. **Show project structure**
   - Displays the current folder structure

8. **Exit**
   - Exits the script

## Examples

### Web Application Example

This example shows how to set up a React web application:

1. Create `project-structure.txt`:
```
# React Web App Structure
root/
  public/
    index.html [file]
    favicon.ico [file]
  src/
    index.js [file]
    App.js [file]
    components/
      Header.js [file]
      Footer.js [file]
    styles/
      main.css [file]
  package.json [file]
  README.md [file]
```

2. Run the generator:
```bash
./project-setup-generator.sh
```

3. Provide details:
```
Project name: My React App
Project description: A modern React web application
Author name: Your Name
Project version: 1.0.0
Path to the folder: ~/project-downloads
```

4. Run the generated setup script:
```bash
bash ~/project-downloads/my-react-app-setup.sh
```

### Backend API Example

This example shows how to set up a Node.js API:

1. Create `project-structure.txt`:
```
# Node.js API Structure
root/
  src/
    index.js [file]
    routes/
      api.js [file]
    controllers/
      userController.js [file]
    models/
      userModel.js [file]
    middleware/
      auth.js [file]
  tests/
    api.test.js [file]
  config/
    default.json [file]
  package.json [file]
  README.md [file]
```

2. Follow the same steps as above, but with different project details.

## Tips for Success

- **Start Simple**: Begin with a basic structure and expand as needed
- **Use the Correct Format**: Pay attention to syntax in your structure file
- **Include All Dependencies**: Make sure all required tools are installed
- **Check Permissions**: Ensure scripts have execute permission (chmod +x)
- **Use Version Control**: Keep your structure definitions in version control
- **Backup Important Files**: Always back up important files before organizing

## Troubleshooting

- **Script fails to run**: Check file permissions and ensure it's executable
- **Structure not recognized**: Verify the format of your structure file
- **Files not organized correctly**: Check that file extensions match expectations
- **Git commands failing**: Ensure Git is installed and properly configured

## Getting Help

If you encounter issues:
1. Check the script for error messages
2. Verify all dependencies are installed
3. Ensure your structure definition is formatted correctly
4. Run the script with verbose output (if available)
5. Check file permissions in your project directories

## Advanced Usage

### Customizing the Generated Setup Script

After generating your setup script, you can modify it to add custom functionality:

1. **Add Custom File Types**:
   - Edit the file organization function to handle additional file extensions
   - Add patterns for special file naming conventions in your project

2. **Add Project-Specific Setup Steps**:
   - Add new functions for project-specific tasks (database setup, config generation)
   - Extend the main menu to include your custom functions

3. **Enhance Git Configuration**:
   - Add additional Git hooks for specialized validation
   - Configure branch protection rules
   - Set up remote repository connections automatically

### Using with Continuous Integration

You can use the generated setup script in CI/CD pipelines:

```bash
# Example CI script
# Clone repository
git clone https://github.com/your-org/your-repo.git

# Run setup script in non-interactive mode
bash ./your-project-setup.sh --non-interactive

# Proceed with build steps
```

### Creating Structure Templates

For teams that frequently create similar projects, consider:

1. Creating a library of structure definition templates
2. Storing them in a shared repository
3. Adding placeholders for project-specific values
4. Using sed/awk to replace placeholders before running the generator

Example template repository structure:
```
structure-templates/
  web-frontend/
    project-structure.txt
  node-api/
    project-structure.txt
  django-app/
    project-structure.txt
```

## Conclusion

The Project Setup Generator helps standardize your development environment and project structure across multiple projects. By investing time in creating good structure definitions, you can ensure consistency and save time on project setup for all future projects.

Remember that the generated setup scripts are fully customizable - they're a starting point that you can adapt to your specific needs as your project evolves.

## Further Resources

- [Git Flow Workflow Documentation](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Project Structure Best Practices](https://docs.github.com/en/get-started/quickstart/create-a-repo)
- [Shell Scripting Guide](https://www.shellscript.sh/)