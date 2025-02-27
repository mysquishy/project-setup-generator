#!/bin/bash

# Project Setup Generator
# A meta-script that generates custom project setup scripts based on input structure definitions
# Version 1.0.0

# Color definitions for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}"
echo "=========================================================="
echo "  Project Setup Generator"
echo "  Creates customized project setup scripts for any project"
echo "=========================================================="
echo -e "${NC}"

# Function to check dependencies
check_dependencies() {
    echo -e "${YELLOW}Checking dependencies...${NC}"
    
    # Check for required commands
    for cmd in jq grep sed awk; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}Error: $cmd is not installed but is required.${NC}"
            echo -e "${YELLOW}Please install $cmd to proceed.${NC}"
            exit 1
        else
            echo -e "${GREEN}✓${NC} $cmd is installed"
        fi
    done
    
    echo -e "${GREEN}All dependencies are installed!${NC}"
}

# Function to get project information
get_project_info() {
    echo -e "${YELLOW}Project Information${NC}"
    read -p "Project name: " PROJECT_NAME
    read -p "Project description: " PROJECT_DESCRIPTION
    read -p "Author name: " AUTHOR_NAME
    read -p "Project version (e.g. 1.0.0): " PROJECT_VERSION
    
    # Construct project name for file paths (lowercase, spaces to dashes)
    PROJECT_DIR_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    echo -e "${GREEN}Project information collected!${NC}"
}

# Function to get path to downloads/source folder
get_source_path() {
    echo -e "${YELLOW}Source Folder Information${NC}"
    read -p "Path to the folder containing downloaded files: " SOURCE_PATH
    
    # Validate path
    if [ ! -d "$SOURCE_PATH" ]; then
        echo -e "${RED}Error: The specified path does not exist.${NC}"
        get_source_path
        return
    fi
    
    echo -e "${GREEN}Source path validated: $SOURCE_PATH${NC}"
    
    # Check if structure definition file exists
    if [ -f "$SOURCE_PATH/project-structure.json" ]; then
        STRUCTURE_FILE="$SOURCE_PATH/project-structure.json"
        STRUCTURE_TYPE="json"
        echo -e "${GREEN}Found JSON structure definition file!${NC}"
    elif [ -f "$SOURCE_PATH/project-structure.txt" ]; then
        STRUCTURE_FILE="$SOURCE_PATH/project-structure.txt"
        STRUCTURE_TYPE="txt"
        echo -e "${GREEN}Found text structure definition file!${NC}"
    else
        echo -e "${YELLOW}No structure definition file found.${NC}"
        echo -e "Please create either:"
        echo -e "- project-structure.json: JSON file defining project structure"
        echo -e "- project-structure.txt: Text file with tree-like structure (indentation indicates hierarchy)"
        echo -e "${YELLOW}Would you like to create a structure definition now?${NC}"
        read -p "Create structure definition? (y/n): " CREATE_STRUCTURE
        
        if [[ $CREATE_STRUCTURE == "y" || $CREATE_STRUCTURE == "Y" ]]; then
            create_structure_definition
        else
            echo -e "${RED}Cannot proceed without structure definition. Exiting.${NC}"
            exit 1
        fi
    fi
}

# Function to create a structure definition file
create_structure_definition() {
    echo -e "${YELLOW}Structure Definition Creation${NC}"
    echo "1. Create JSON structure definition"
    echo "2. Create text-based structure definition"
    read -p "Select format (1-2): " FORMAT_CHOICE
    
    if [ "$FORMAT_CHOICE" == "1" ]; then
        # Create JSON template
        STRUCTURE_FILE="$SOURCE_PATH/project-structure.json"
        STRUCTURE_TYPE="json"
        
        cat > "$STRUCTURE_FILE" << 'EOL'
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
EOL
        echo -e "${GREEN}Created JSON structure template at $STRUCTURE_FILE${NC}"
        echo -e "${YELLOW}Please edit this file to match your project structure and run this script again.${NC}"
        
    else
        # Create text template
        STRUCTURE_FILE="$SOURCE_PATH/project-structure.txt"
        STRUCTURE_TYPE="txt"
        
        cat > "$STRUCTURE_FILE" << 'EOL'
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
EOL
        echo -e "${GREEN}Created text structure template at $STRUCTURE_FILE${NC}"
        echo -e "${YELLOW}Please edit this file to match your project structure and run this script again.${NC}"
    fi
    
    echo -e "${YELLOW}Would you like to open the structure file in an editor now?${NC}"
    read -p "Open file? (y/n): " OPEN_FILE
    
    if [[ $OPEN_FILE == "y" || $OPEN_FILE == "Y" ]]; then
        # Try to find an appropriate editor
        if command -v nano &> /dev/null; then
            nano "$STRUCTURE_FILE"
        elif command -v vim &> /dev/null; then
            vim "$STRUCTURE_FILE"
        elif command -v code &> /dev/null; then
            code "$STRUCTURE_FILE"
        else
            echo -e "${YELLOW}No suitable editor found. Please edit the file manually.${NC}"
        fi
    fi
    
    echo -e "${RED}Please edit the structure definition and run this script again.${NC}"
    exit 0
}

# Function to parse structure definition file
parse_structure() {
    echo -e "${YELLOW}Parsing project structure...${NC}"
    
    if [ "$STRUCTURE_TYPE" == "json" ]; then
        # Validate JSON
        if ! jq . "$STRUCTURE_FILE" > /dev/null 2>&1; then
            echo -e "${RED}Error: Invalid JSON in structure file.${NC}"
            exit 1
        fi
        
        # Extract directories
        DIRECTORIES=$(jq -r '.. | select(.type? == "directory") | .name' "$STRUCTURE_FILE" | grep -v "^root$")
        
        # Extract files
        FILES=$(jq -r '.. | select(.type? == "file") | .name' "$STRUCTURE_FILE")
        
    elif [ "$STRUCTURE_TYPE" == "txt" ]; then
        # Process text-based structure, ignoring comments and blank lines
        STRUCTURE_CONTENT=$(grep -v "^#" "$STRUCTURE_FILE" | grep -v "^$")
        
        # Extract directories (lines ending with /)
        DIRECTORIES=$(echo "$STRUCTURE_CONTENT" | grep -v "\[file\]" | sed 's/^[ \t]*//' | sed 's/\/$//' | grep -v "^root$")
        
        # Extract files (lines with [file] marker)
        FILES=$(echo "$STRUCTURE_CONTENT" | grep "\[file\]" | sed 's/^[ \t]*//' | sed 's/ \[file\]$//')
    fi
    
    echo -e "${GREEN}Structure parsed successfully!${NC}"
    echo -e "${BLUE}Found $(echo "$DIRECTORIES" | wc -l | tr -d ' ') directories and $(echo "$FILES" | wc -l | tr -d ' ') files${NC}"
}

# Function to detect file patterns
detect_file_patterns() {
    echo -e "${YELLOW}Detecting file patterns and project type...${NC}"
    
    # Check for common file types and project indicators
    HAS_PACKAGE_JSON=false
    HAS_COMPOSER_JSON=false
    HAS_GEMFILE=false
    HAS_REQUIREMENTS_TXT=false
    HAS_MAKEFILE=false
    HAS_GRADLE=false
    HAS_POM_XML=false
    HAS_DOCKER=false
    
    # Look for technology indicators in structure
    if echo "$FILES" | grep -q "package.json"; then
        HAS_PACKAGE_JSON=true
        echo -e "${GREEN}✓${NC} Detected Node.js/JavaScript project (package.json)"
    fi
    if echo "$FILES" | grep -q "composer.json"; then
        HAS_COMPOSER_JSON=true
        echo -e "${GREEN}✓${NC} Detected PHP project (composer.json)"
    fi
    if echo "$FILES" | grep -q "Gemfile"; then
        HAS_GEMFILE=true
        echo -e "${GREEN}✓${NC} Detected Ruby project (Gemfile)"
    fi
    if echo "$FILES" | grep -q "requirements.txt"; then
        HAS_REQUIREMENTS_TXT=true
        echo -e "${GREEN}✓${NC} Detected Python project (requirements.txt)"
    fi
    if echo "$FILES" | grep -q "Makefile"; then
        HAS_MAKEFILE=true
        echo -e "${GREEN}✓${NC} Detected project with Make build system"
    fi
    if echo "$FILES" | grep -q "build.gradle"; then
        HAS_GRADLE=true
        echo -e "${GREEN}✓${NC} Detected Java/Kotlin project with Gradle"
    fi
    if echo "$FILES" | grep -q "pom.xml"; then
        HAS_POM_XML=true
        echo -e "${GREEN}✓${NC} Detected Java project with Maven"
    fi
    if echo "$FILES" | grep -q "Dockerfile" || echo "$FILES" | grep -q "docker-compose.yml"; then
        HAS_DOCKER=true
        echo -e "${GREEN}✓${NC} Detected Docker configuration"
    fi
    
    # Detect primary language based on file extensions
    JS_COUNT=$(echo "$FILES" | grep -c "\.js$")
    PY_COUNT=$(echo "$FILES" | grep -c "\.py$")
    JAVA_COUNT=$(echo "$FILES" | grep -c "\.java$")
    TS_COUNT=$(echo "$FILES" | grep -c "\.ts$")
    PHP_COUNT=$(echo "$FILES" | grep -c "\.php$")
    RB_COUNT=$(echo "$FILES" | grep -c "\.rb$")
    GO_COUNT=$(echo "$FILES" | grep -c "\.go$")
    
    # Determine primary language
    PRIMARY_LANGUAGE="unknown"
    MAX_COUNT=0
    
    if [ "$JS_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="javascript"
        MAX_COUNT=$JS_COUNT
    fi
    if [ "$PY_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="python"
        MAX_COUNT=$PY_COUNT
    fi
    if [ "$JAVA_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="java" 
        MAX_COUNT=$JAVA_COUNT
    fi
    if [ "$TS_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="typescript"
        MAX_COUNT=$TS_COUNT
    fi
    if [ "$PHP_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="php"
        MAX_COUNT=$PHP_COUNT
    fi
    if [ "$RB_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="ruby"
        MAX_COUNT=$RB_COUNT
    fi
    if [ "$GO_COUNT" -gt "$MAX_COUNT" ]; then
        PRIMARY_LANGUAGE="go"
        MAX_COUNT=$GO_COUNT
    fi
    
    echo -e "${GREEN}Primary language detected: ${BLUE}$PRIMARY_LANGUAGE${NC}"
    
    # Allow language override
    read -p "Use $PRIMARY_LANGUAGE as primary language? (y/n): " LANGUAGE_CONFIRM
    if [[ $LANGUAGE_CONFIRM != "y" && $LANGUAGE_CONFIRM != "Y" ]]; then
        echo "Available languages:"
        echo "1. JavaScript"
        echo "2. Python"
        echo "3. Java"
        echo "4. TypeScript"
        echo "5. PHP"
        echo "6. Ruby"
        echo "7. Go"
        echo "8. Other (specify)"
        read -p "Select language (1-8): " LANGUAGE_CHOICE
        
        case $LANGUAGE_CHOICE in
            1) PRIMARY_LANGUAGE="javascript" ;;
            2) PRIMARY_LANGUAGE="python" ;;
            3) PRIMARY_LANGUAGE="java" ;;
            4) PRIMARY_LANGUAGE="typescript" ;;
            5) PRIMARY_LANGUAGE="php" ;;
            6) PRIMARY_LANGUAGE="ruby" ;;
            7) PRIMARY_LANGUAGE="go" ;;
            8) 
                read -p "Specify language: " PRIMARY_LANGUAGE
                PRIMARY_LANGUAGE=$(echo "$PRIMARY_LANGUAGE" | tr '[:upper:]' '[:lower:]')
                ;;
            *) echo -e "${RED}Invalid choice. Using detected language: $PRIMARY_LANGUAGE${NC}" ;;
        esac
    fi
    
    echo -e "${GREEN}Selected primary language: ${BLUE}$PRIMARY_LANGUAGE${NC}"
}

# Function to generate setup script
generate_setup_script() {
    SETUP_SCRIPT_PATH="$SOURCE_PATH/${PROJECT_DIR_NAME}-setup.sh"
    echo -e "${YELLOW}Generating setup script at $SETUP_SCRIPT_PATH...${NC}"
    
    # Create setup script with header
    cat > "$SETUP_SCRIPT_PATH" << EOL
#!/bin/bash

# $PROJECT_NAME Setup Script
# $PROJECT_DESCRIPTION
# Generated by Project Setup Generator
# Version: $PROJECT_VERSION
# Author: $AUTHOR_NAME
# Generated on: $(date)

# Color definitions for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print banner
echo -e "\${BLUE}"
echo "=========================================================="
echo "  $PROJECT_NAME Setup"
echo "  $PROJECT_DESCRIPTION"
echo "=========================================================="
echo -e "\${NC}"

# Set base directory to current location
BASE_DIR=\$(pwd)
MAIN_DIR="\$BASE_DIR/$PROJECT_DIR_NAME"
DOWNLOADS_DIR="\$BASE_DIR/downloads"

# Check if the downloads directory exists
if [ ! -d "\$DOWNLOADS_DIR" ]; then
    echo -e "\${YELLOW}Creating downloads directory...\${NC}"
    mkdir -p "\$DOWNLOADS_DIR"
    echo -e "\${GREEN}Created downloads directory at \$DOWNLOADS_DIR\${NC}"
fi

# Create main project directory if it doesn't exist
if [ ! -d "\$MAIN_DIR" ]; then
    echo -e "\${YELLOW}Creating main project directory...\${NC}"
    mkdir -p "\$MAIN_DIR"
    echo -e "\${GREEN}Created main project directory at \$MAIN_DIR\${NC}"
else
    echo -e "\${YELLOW}Main project directory already exists at \$MAIN_DIR\${NC}"
    read -p "Do you want to rebuild the structure? This won't delete existing files. (y/n): " rebuild
    if [[ \$rebuild != "y" && \$rebuild != "Y" ]]; then
        echo -e "\${YELLOW}Skipping structure creation. Will only organize downloads.\${NC}"
    fi
fi

# Create project structure if rebuilding or new project
if [[ ! -d "\$MAIN_DIR" || \$rebuild == "y" || \$rebuild == "Y" ]]; then
    echo -e "\${YELLOW}Creating project structure...\${NC}"
    
    # Create directories
EOL
    
    # Add directory creation
    for dir in $DIRECTORIES; do
        echo "    mkdir -p \"\$MAIN_DIR/$dir\"" >> "$SETUP_SCRIPT_PATH"
    done
    
    echo "" >> "$SETUP_SCRIPT_PATH"
    echo "    # Create placeholder files" >> "$SETUP_SCRIPT_PATH"
    
    # Add file creation
    for file in $FILES; do
        dir=$(dirname "$file")
        if [ "$dir" = "." ]; then
            echo "    touch \"\$MAIN_DIR/$file\"" >> "$SETUP_SCRIPT_PATH"
        else
            echo "    touch \"\$MAIN_DIR/$file\"" >> "$SETUP_SCRIPT_PATH"
        fi
    done
    
    echo "" >> "$SETUP_SCRIPT_PATH"
    echo "    echo -e \"\${GREEN}Created project structure successfully!\${NC}\"" >> "$SETUP_SCRIPT_PATH"
    echo "fi" >> "$SETUP_SCRIPT_PATH"
    echo "" >> "$SETUP_SCRIPT_PATH"
    
    # Add file organization function
    cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
# Function to organize files
organize_files() {
    echo -e "${YELLOW}Organizing files from downloads directory...${NC}"
    
    # Count files before starting
    file_count=$(find "$DOWNLOADS_DIR" -type f | wc -l)
    if [ "$file_count" -eq 0 ]; then
        echo -e "${RED}No files found in downloads directory. Please add files before organizing.${NC}"
        return
    fi
    
    # Create a temporary log file to track what we've moved
    LOG_FILE="$BASE_DIR/file_organization.log"
    echo "File Organization Log - $(date)" > "$LOG_FILE"
    echo "====================================" >> "$LOG_FILE"
    
    # Counter for moved files
    moved_files=0
EOL
    
    # Add file type detection and organization based on project type
    if [ "$PRIMARY_LANGUAGE" == "javascript" ] || [ "$PRIMARY_LANGUAGE" == "typescript" ]; then
        cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
    # Organize JS/TS files
    echo -e "${BLUE}Organizing JavaScript/TypeScript files...${NC}"
    
    # Core files
    for file in $(find "$DOWNLOADS_DIR" -name "*.js" -o -name "*.ts" -o -name "*.json"); do
        filename=$(basename "$file")
        if [ -f "$file" ]; then
            if [[ "$filename" == "package.json" || "$filename" == "tsconfig.json" ]]; then
                cp "$file" "$MAIN_DIR/"
                echo "Moved $filename to project root" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → project root"
            elif [[ "$filename" == *".config.js" || "$filename" == *".config.ts" ]]; then
                cp "$file" "$MAIN_DIR/"
                echo "Moved $filename to project root" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → project root"
            fi
        fi
    done
    
    # Source files
    for file in $(find "$DOWNLOADS_DIR" -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx"); do
        filename=$(basename "$file")
        if [ -f "$file" ] && [[ "$filename" != *".config."* ]]; then
            # Try to determine the best destination based on filename patterns
            if [[ "$filename" == "index.js" || "$filename" == "index.ts" ]]; then
                cp "$file" "$MAIN_DIR/src/"
                echo "Moved $filename to src/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/"
            elif [[ "$filename" == *".component."* || "$filename" == *".service."* ]]; then
                cp "$file" "$MAIN_DIR/src/components/"
                echo "Moved $filename to src/components/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/components/"
            elif [[ "$filename" == *".test."* || "$filename" == *".spec."* ]]; then
                cp "$file" "$MAIN_DIR/tests/"
                echo "Moved $filename to tests/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → tests/"
            elif [[ "$filename" == *".util."* || "$filename" == *"helper"* ]]; then
                cp "$file" "$MAIN_DIR/src/utils/"
                echo "Moved $filename to src/utils/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/utils/"
            else
                cp "$file" "$MAIN_DIR/src/"
                echo "Moved $filename to src/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/"
            fi
        fi
    done
EOL
    elif [ "$PRIMARY_LANGUAGE" == "python" ]; then
        cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
    # Organize Python files
    echo -e "${BLUE}Organizing Python files...${NC}"
    
    # Core files
    for file in $(find "$DOWNLOADS_DIR" -name "*.py" -o -name "requirements.txt" -o -name "setup.py"); do
        filename=$(basename "$file")
        if [ -f "$file" ]; then
            if [[ "$filename" == "requirements.txt" || "$filename" == "setup.py" ]]; then
                cp "$file" "$MAIN_DIR/"
                echo "Moved $filename to project root" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → project root"
            elif [[ "$filename" == "__init__.py" ]]; then
                # Find appropriate module directories and copy __init__.py there
                for dir in $(find "$MAIN_DIR" -type d -not -path "*/\.*"); do
                    if [ "$dir" != "$MAIN_DIR" ]; then
                        cp "$file" "$dir/"
                        echo "Moved $filename to $(basename $dir)/" >> "$LOG_FILE"
                        ((moved_files++))
                        echo -e "  ${GREEN}✓${NC} $filename → $(basename $dir)/"
                    fi
                done
            elif [[ "$filename" == *"_test.py" || "$filename" == "test_"* ]]; then
                cp "$file" "$MAIN_DIR/tests/"
                echo "Moved $filename to tests/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → tests/"
            else
                cp "$file" "$MAIN_DIR/src/"
                echo "Moved $filename to src/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/"
            fi
        fi
    done
EOL
    else
        # Generic file organization for other languages
        cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
    # Organize files based on extensions
    echo -e "${BLUE}Organizing files by type...${NC}"
    
    # Documentation files
    for file in $(find "$DOWNLOADS_DIR" -name "*.md" -o -name "*.txt" -o -name "*.pdf" -o -name "*.doc" -o -name "*.docx"); do
        filename=$(basename "$file")
        if [ -f "$file" ]; then
            if [[ "$filename" == "README.md" ]]; then
                cp "$file" "$MAIN_DIR/"
                echo "Moved $filename to project root" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → project root"
            else
                cp "$file" "$MAIN_DIR/docs/"
                echo "Moved $filename to docs/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → docs/"
            fi
        fi
    done
    
    # Source code files (add extensions based on your primary language)
    for file in $(find "$DOWNLOADS_DIR" -name "*.js" -o -name "*.py" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" -o -name "*.go" -o -name "*.php" -o -name "*.rb"); do
        filename=$(basename "$file")
        if [ -f "$file" ]; then
            if [[ "$filename" == *"test"* || "$filename" == *"Test"* ]]; then
                cp "$file" "$MAIN_DIR/tests/"
                echo "Moved $filename to tests/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → tests/"
            else
                cp "$file" "$MAIN_DIR/src/"
                echo "Moved $filename to src/" >> "$LOG_FILE"
                ((moved_files++))
                echo -e "  ${GREEN}✓${NC} $filename → src/"
            fi
        fi
    done
    
    # Configuration files
    for file in $(find "$DOWNLOADS_DIR" -name "*.json" -o -name "*.xml" -o -name "*.yml" -o -name "*.yaml" -o -name "*.config" -o -name "*.conf" -o -name "*.properties"); do
        filename=$(basename "$file")
        if [ -f "$file" ]; then
            cp "$file" "$MAIN_DIR/"
            echo "Moved $filename to project root" >> "$LOG_FILE"
            ((moved_files++))
            echo -e "  ${GREEN}✓${NC} $filename → project root"
        fi
    done
EOL
    fi
    
    # Add rest of organize_files function
    cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
    # Report results
    echo ""
    if [ "$moved_files" -gt 0 ]; then
        echo -e "${GREEN}Successfully organized $moved_files files!${NC}"
        echo -e "${YELLOW}Organization log saved to $LOG_FILE${NC}"
    else
        echo -e "${RED}No matching files were found to organize.${NC}"
        echo "No files were moved." >> "$LOG_FILE"
    fi
}
EOL
    
    # Add Git setup function
    cat >> "$SETUP_SCRIPT_PATH" << 'EOL'
# Set up basic Git repository
setup_git() {
    echo -e "${YELLOW}Setting up Git repository...${NC}"
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Git is not installed. Please install Git to proceed with repository setup.${NC}"
        return
    fi
    
    # Navigate to project directory
    cd "$MAIN_DIR"
    
    # Check if it's already a git repository
    if [ -d ".git" ]; then
        echo -e "${YELLOW}Git repository already exists.${NC}"
        
        # Check if branches exist
        if git show-ref --quiet refs/heads/main; then
            echo -e "  ${GREEN}✓${NC} main branch exists"
        else
            echo -e "  ${YELLOW}Creating main branch...${NC}"
            # Check current branch name
            current_branch=$(git rev-parse --abbrev-ref HEAD)
            if [ "$current_branch" == "master" ]; then
                git branch -m master main
                echo -e "  ${GREEN}✓${NC} Renamed master branch to main"
            else
                git checkout -b main
                echo -e "  ${GREEN}✓${NC} Created main branch"
            fi
        fi
        
        # Check if develop branch exists
        if git show-ref --quiet refs/heads/develop; then
            echo -e "  ${GREEN}✓${NC} develop branch exists"
        else
            echo -e "  ${YELLOW}Creating develop branch...${NC}"
            git checkout -b develop
            echo -e "  ${GREEN}✓${NC} Created develop branch"
            
            # Switch back to main
            git checkout main
        fi
    else
        # Initialize new repository
        echo -e "${YELLOW}Initializing new Git repository...${NC}"
        git init
        
        # Create .gitignore file if it doesn't exist
        if [ ! -f ".gitignore" ]; then
            echo -e "${YELLOW}Creating .gitignore file..${NC}"
            
            # Add common patterns based on language
            case "$PRIMARY_LANGUAGE" in
                javascript|typescript)
                    echo "node_modules/" > .gitignore
                    echo "npm-debug.log" >> .gitignore
                    echo "yarn-error.log" >> .gitignore
                    echo "dist/" >> .gitignore
                    echo "coverage/" >> .gitignore
                    echo ".env" >> .gitignore
                    ;;
                python)
                    echo "__pycache__/" > .gitignore
                    echo "*.py[cod]" >> .gitignore
                    echo "*$py.class" >> .gitignore
                    echo "venv/" >> .gitignore
                    echo "env/" >> .gitignore
                    echo ".env" >> .gitignore
                    echo "*.so" >> .gitignore
                    echo ".Python" >> .gitignore
                    echo "build/" >> .gitignore
                    echo "develop-eggs/" >> .gitignore
                    echo "dist/" >> .gitignore
                    echo "downloads/" >> .gitignore
                    echo "eggs/" >> .gitignore
                    echo ".eggs/" >> .gitignore
                    ;;
                java)
                    echo "*.class" > .gitignore
                    echo "*.log" >> .gitignore
                    echo "*.jar" >> .gitignore
                    echo "*.war" >> .gitignore
                    echo "*.ear" >> .gitignore
                    echo "hs_err_pid*" >> .gitignore
                    echo "target/" >> .gitignore
                    echo ".classpath" >> .gitignore
                    echo ".project" >> .gitignore
                    echo ".settings/" >> .gitignore
                    ;;
                go)
                    echo "# Binaries for programs and plugins" > .gitignore
                    echo "*.exe" >> .gitignore
                    echo "*.exe~" >> .gitignore
                    echo "*.dll" >> .gitignore
                    echo "*.so" >> .gitignore
                    echo "*.dylib" >> .gitignore
                    echo "# Test binary, built with 'go test -c'" >> .gitignore
                    echo "*.test" >> .gitignore
                    echo "# Output of the go coverage tool" >> .gitignore
                    echo "*.out" >> .gitignore
                    ;;
                php)
                    echo "vendor/" > .gitignore
                    echo "composer.phar" >> .gitignore
                    echo "composer.lock" >> .gitignore
                    echo ".env" >> .gitignore
                    ;;
                ruby)
                    echo "*.gem" > .gitignore
                    echo "*.rbc" >> .gitignore
                    echo "/.config" >> .gitignore
                    echo "coverage/" >> .gitignore
                    echo "/InstalledFiles" >> .gitignore
                    echo "/pkg/" >> .gitignore
                    echo "/spec/reports/" >> .gitignore
                    echo ".bundle/" >> .gitignore
                    echo "vendor/bundle" >> .gitignore
                    ;;
                *)
                    echo ".DS_Store" > .gitignore
                    echo "*.log" >> .gitignore
                    echo "*.bak" >> .gitignore
                    echo "*.tmp" >> .gitignore
                    echo "*.swp" >> .gitignore
                    echo ".env" >> .gitignore
                    ;;
            esac
            
            # Add IDE-specific patterns
            echo "" >> .gitignore
            echo "# IDE files" >> .gitignore
            echo ".idea/" >> .gitignore
            echo ".vscode/" >> .gitignore
            echo "*.sublime-*" >> .gitignore
            echo "*.iml" >> .gitignore
            
            echo -e "  ${GREEN}✓${NC} Created .gitignore file based on $PRIMARY_LANGUAGE project type"
        fi
        
        # Initial commit
        git add .
        git commit -m "Initial project structure"
        
        # Rename branch to main if on master
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" == "master" ]; then
            git branch -m master main
        fi
        
        echo -e "  ${GREEN}✓${NC} Initialized repository with main branch"
        
        # Create develop branch
        git checkout -b develop
        echo -e "  ${GREEN}✓${NC} Created develop branch"
        
        # Switch back to main
        git checkout main
    fi
    
    # Return to base directory
    cd "$BASE_DIR"
    
    echo -e "${GREEN}Git repository setup complete!${NC}"
}

# Function to create commit templates
create_commit_templates() {
    echo -e "${YELLOW}Creating commit message templates...${NC}"
    
    # Create .gitmessage template file
    cat > "$MAIN_DIR/.gitmessage" << 'EOL'
# <type>(<scope>): <subject>
# |<----  Using a Maximum Of 50 Characters  ---->|

# Explain why this change is being made
# |<----   Try To Limit Each Line to a Maximum Of 72 Characters   ---->|

# Provide links or keys to any relevant tickets, articles or other resources
# Example: Github issue #23

# --- COMMIT END ---
# Types:
#   feat      (new feature)
#   fix       (bug fix)
#   docs      (changes to documentation)
#   style     (formatting, missing semi colons, etc; no code change)
#   refactor  (refactoring production code)
#   test      (adding missing tests, refactoring tests; no production code change)
#   chore     (updating grunt tasks etc; no production code change)
# --------------------
# Remember to:
#   * Use the imperative, present tense: "change" not "changed" nor "changes"
#   * Don't capitalize the first letter
#   * No period (.) at the end
EOL
    
    # Configure git to use the template
    cd "$MAIN_DIR"
    git config commit.template .gitmessage
    
    echo -e "${GREEN}Created commit message template and configured git to use it.${NC}"
}

# Function to setup and configure git hooks
setup_git_hooks() {
    echo -e "${YELLOW}Setting up git hooks...${NC}"
    
    # Create hooks directory if it doesn't exist
    mkdir -p "$MAIN_DIR/.git/hooks"
    
    # Create pre-commit hook for basic validation
    cat > "$MAIN_DIR/.git/hooks/pre-commit" << 'EOL'
#!/bin/bash

# Pre-commit hook
echo "Running pre-commit checks..."

# Check for console.log statements that shouldn't be committed
FOUND_CONSOLE_LOGS=$(git diff --cached --name-only | grep -E '\.js | xargs grep -l "console\.log" 2>/dev/null)
if [ -n "$FOUND_CONSOLE_LOGS" ]; then
    echo "Warning: console.log statements found in the following files:"
    echo "$FOUND_CONSOLE_LOGS"
    echo "Do you want to continue with the commit? (y/n)"
    read -r CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo "Commit aborted. Please remove or comment out console.log statements."
        exit 1
    fi
fi

# Check for debugging code
FOUND_DEBUG=$(git diff --cached --name-only | grep -E '\.js | xargs grep -l "debugger;" 2>/dev/null)
if [ -n "$FOUND_DEBUG" ]; then
    echo "Warning: 'debugger;' statements found in the following files:"
    echo "$FOUND_DEBUG"
    echo "Do you want to continue with the commit? (y/n)"
    read -r CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo "Commit aborted. Please remove debugger statements before committing."
        exit 1
    fi
fi

echo "Pre-commit checks completed successfully"
exit 0
EOL
    
    # Make the hook executable
    chmod +x "$MAIN_DIR/.git/hooks/pre-commit"
    
    # Create commit-msg hook for validating commit messages
    cat > "$MAIN_DIR/.git/hooks/commit-msg" << 'EOL'
#!/bin/bash

# commit-msg hook
# Validates that commit messages follow the conventional commits format

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Ignore merge commits
if [[ "$COMMIT_MSG" =~ ^Merge\ branch ]]; then
    exit 0
fi

# Check if the commit message follows the conventional format
if ! [[ "$COMMIT_MSG" =~ ^(feat|fix|docs|style|refactor|perf|test|chore)(\([a-z]+\))?:\ .+ ]]; then
    echo "Error: Commit message does not follow the conventional format."
    echo "Please use the format: type(scope): subject"
    echo "Example: feat(user): add user authentication"
    echo ""
    echo "Types: feat, fix, docs, style, refactor, perf, test, chore"
    exit 1
fi

# Check subject line length
SUBJECT=$(echo "$COMMIT_MSG" | head -1)
if [ ${#SUBJECT} -gt 50 ]; then
    echo "Error: Commit subject line is too long (${#SUBJECT} > 50 characters)"
    exit 1
fi

exit 0
EOL
    
    # Make the hook executable
    chmod +x "$MAIN_DIR/.git/hooks/commit-msg"
    
    echo -e "${GREEN}Git hooks setup completed successfully.${NC}"
}

# Function to generate a README file
generate_readme() {
    echo -e "${YELLOW}Generating README.md file...${NC}"
    
    # Check if README.md already exists
    if [ -f "$MAIN_DIR/README.md" ]; then
        echo -e "${YELLOW}README.md already exists. Do you want to overwrite it?${NC}"
        read -p "Overwrite? (y/n): " OVERWRITE
        if [[ $OVERWRITE != "y" && $OVERWRITE != "Y" ]]; then
            echo -e "${YELLOW}Skipping README.md generation.${NC}"
            return
        fi
    fi
    
    # Create README.md
    cat > "$MAIN_DIR/README.md" << EOL
# $PROJECT_NAME

$PROJECT_DESCRIPTION

## Project Structure

\`\`\`
$PROJECT_DIR_NAME/
$(for dir in $DIRECTORIES; do echo "├── $dir/"; done)
$(for file in $FILES; do echo "├── $file"; done)
\`\`\`

## Getting Started

### Prerequisites

$(case $PRIMARY_LANGUAGE in
    javascript|typescript)
        echo "- Node.js"
        echo "- npm or yarn"
        ;;
    python)
        echo "- Python 3.6+"
        echo "- pip"
        ;;
    java)
        echo "- JDK 8+"
        echo "- Maven or Gradle"
        ;;
    go)
        echo "- Go 1.13+"
        ;;
    php)
        echo "- PHP 7.4+"
        echo "- Composer"
        ;;
    ruby)
        echo "- Ruby 2.7+"
        echo "- Bundler"
        ;;
    *)
        echo "- List your prerequisites here"
        ;;
esac)

### Installation

1. Clone the repository
   \`\`\`bash
   git clone <your-repo-url>
   cd $PROJECT_DIR_NAME
   \`\`\`

2. Install dependencies
   \`\`\`bash
$(case $PRIMARY_LANGUAGE in
    javascript|typescript)
        echo "   npm install"
        ;;
    python)
        echo "   pip install -r requirements.txt"
        ;;
    java)
        if [ "$HAS_GRADLE" = true ]; then
            echo "   ./gradlew build"
        elif [ "$HAS_POM_XML" = true ]; then
            echo "   mvn install"
        fi
        ;;
    php)
        echo "   composer install"
        ;;
    ruby)
        echo "   bundle install"
        ;;
    go)
        echo "   go mod download"
        ;;
    *)
        echo "   # Add installation steps here"
        ;;
esac)
   \`\`\`

## Usage

Add usage instructions here.

## Development

This project follows the GitFlow workflow with \`main\` and \`develop\` branches.

- \`main\`: Production-ready code
- \`develop\`: Latest development changes

For new features, create a feature branch from \`develop\`:
\`\`\`bash
git checkout -b feature/your-feature-name develop
\`\`\`

## License

This project is licensed under the [License Name] - see the LICENSE file for details.

## Author

$AUTHOR_NAME
EOL
    
    echo -e "${GREEN}README.md generated successfully!${NC}"
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}"
        echo "=========================================================="
        echo "  Project Setup Menu"
        echo "=========================================================="
        echo -e "${NC}"
        echo "1. Create/rebuild project structure"
        echo "2. Organize files from downloads directory"
        echo "3. Setup Git repository (main & develop branches)"
        echo "4. Create Git commit templates"
        echo "5. Setup Git hooks"
        echo "6. Generate README.md"
        echo "7. Show project structure"
        echo "8. Exit"
        
        read -p "Select an option (1-8): " option
        
        case $option in
            1)
                # Create project directory code here
                if [ ! -d "$MAIN_DIR" ]; then
                    mkdir -p "$MAIN_DIR"
                    echo -e "${GREEN}Created main project directory at $MAIN_DIR${NC}"
                    rebuild="y"
                else
                    echo -e "${YELLOW}Main project directory already exists at $MAIN_DIR${NC}"
                    read -p "Do you want to rebuild the structure? This won't delete existing files. (y/n): " rebuild
                fi
                
                if [[ $rebuild == "y" || $rebuild == "Y" ]]; then
                    echo -e "${YELLOW}Creating project structure...${NC}"
                    
                    # Create directories
                    for dir in $DIRECTORIES; do
                        mkdir -p "$MAIN_DIR/$dir"
                        echo -e "  ${GREEN}✓${NC} Created directory: $dir"
                    done
                    
                    # Create files
                    for file in $FILES; do
                        touch "$MAIN_DIR/$file"
                        echo -e "  ${GREEN}✓${NC} Created file: $file"
                    done
                    
                    echo -e "${GREEN}Created project structure successfully!${NC}"
                fi
                ;;
            2) organize_files ;;
            3) setup_git ;;
            4) create_commit_templates ;;
            5) setup_git_hooks ;;
            6) generate_readme ;;
            7)
                echo -e "${BLUE}=====================================================${NC}"
                echo -e "${YELLOW}Project structure:${NC}"
                echo -e "${BLUE}$PROJECT_DIR_NAME/${NC}"
                for dir in $DIRECTORIES; do
                    echo -e "├── $dir/"
                done
                for file in $FILES; do
                    echo -e "├── $file"
                done
                echo -e "${BLUE}=====================================================${NC}"
                ;;
            8) 
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main execution flow
check_dependencies
get_project_info
get_source_path
parse_structure
detect_file_patterns

# Generate the setup script
generate_setup_script

# Make the setup script executable
chmod +x "$SETUP_SCRIPT_PATH"
echo -e "${GREEN}Setup script generated successfully at $SETUP_SCRIPT_PATH${NC}"
echo -e "${YELLOW}Run the script with: bash $SETUP_SCRIPT_PATH${NC}"
