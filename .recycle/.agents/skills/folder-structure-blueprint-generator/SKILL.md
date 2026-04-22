---
name: folder-structure-blueprint-generator
description: 'Comprehensive technology-agnostic prompt for analyzing and documenting project folder structures. Auto-detects project types (.NET, Java, React, Angular, Python, Node.js, Flutter), generates detailed blueprints with visualization options, naming conventions, file placement patterns, and extension templates for maintaining consistent code organization across diverse technology stacks.'
---

# Project Folder Structure Blueprint Generator

## Configuration Variables

<<<<<<< HEAD
${PROJECT_TYPE="Auto-detect|.NET|Java|React|Angular|Python|Node.js|Flutter|Other"}
<!-- Select primary technology -->

${INCLUDES_MICROSERVICES="Auto-detect|true|false"}
<!-- Is this a microservices architecture? -->

${INCLUDES_FRONTEND="Auto-detect|true|false"}
<!-- Does project include frontend components? -->

${IS_MONOREPO="Auto-detect|true|false"}
<!-- Is this a monorepo with multiple projects? -->

${VISUALIZATION_STYLE="ASCII|Markdown List|Table"}
<!-- How to visualize the structure -->

${DEPTH_LEVEL=1-5}
<!-- How many levels of folders to document in detail -->

${INCLUDE_FILE_COUNTS=true|false}
<!-- Include file count statistics -->

${INCLUDE_GENERATED_FOLDERS=true|false}
<!-- Include auto-generated folders -->

${INCLUDE_FILE_PATTERNS=true|false}
<!-- Document file naming/location patterns -->

${INCLUDE_TEMPLATES=true|false}
=======
${PROJECT_TYPE="Auto-detect|.NET|Java|React|Angular|Python|Node.js|Flutter|Other"} 
<!-- Select primary technology -->

${INCLUDES_MICROSERVICES="Auto-detect|true|false"} 
<!-- Is this a microservices architecture? -->

${INCLUDES_FRONTEND="Auto-detect|true|false"} 
<!-- Does project include frontend components? -->

${IS_MONOREPO="Auto-detect|true|false"} 
<!-- Is this a monorepo with multiple projects? -->

${VISUALIZATION_STYLE="ASCII|Markdown List|Table"} 
<!-- How to visualize the structure -->

${DEPTH_LEVEL=1-5} 
<!-- How many levels of folders to document in detail -->

${INCLUDE_FILE_COUNTS=true|false} 
<!-- Include file count statistics -->

${INCLUDE_GENERATED_FOLDERS=true|false} 
<!-- Include auto-generated folders -->

${INCLUDE_FILE_PATTERNS=true|false} 
<!-- Document file naming/location patterns -->

${INCLUDE_TEMPLATES=true|false} 
>>>>>>> origin/main
<!-- Include file/folder templates for new features -->

## Generated Prompt

"Analyze the project's folder structure and create a comprehensive 'Project_Folders_Structure_Blueprint.md' document that serves as a definitive guide for maintaining consistent code organization. Use the following approach:

### Initial Auto-detection Phase

<<<<<<< HEAD
${PROJECT_TYPE == "Auto-detect" ?
=======
${PROJECT_TYPE == "Auto-detect" ? 
>>>>>>> origin/main
"Begin by scanning the folder structure for key files that identify the project type:
- Look for solution/project files (.sln, .csproj, .fsproj, .vbproj) to identify .NET projects
- Check for build files (pom.xml, build.gradle, settings.gradle) for Java projects
- Identify package.json with dependencies for JavaScript/TypeScript projects
- Look for specific framework files (angular.json, react-scripts entries, next.config.js)
- Check for Python project identifiers (requirements.txt, setup.py, pyproject.toml)
- Examine mobile app identifiers (pubspec.yaml, android/ios folders)
<<<<<<< HEAD
- Note all technology signatures found and their versions" :
"Focus analysis on ${PROJECT_TYPE} project structure"}

${IS_MONOREPO == "Auto-detect" ?
=======
- Note all technology signatures found and their versions" : 
"Focus analysis on ${PROJECT_TYPE} project structure"}

${IS_MONOREPO == "Auto-detect" ? 
>>>>>>> origin/main
"Determine if this is a monorepo by looking for:
- Multiple distinct projects with their own configuration files
- Workspace configuration files (lerna.json, nx.json, turborepo.json, etc.)
- Cross-project references and shared dependency patterns
- Root-level orchestration scripts and configuration" : ""}

<<<<<<< HEAD
${INCLUDES_MICROSERVICES == "Auto-detect" ?
=======
${INCLUDES_MICROSERVICES == "Auto-detect" ? 
>>>>>>> origin/main
"Check for microservices architecture indicators:
- Multiple service directories with similar/repeated structures
- Service-specific Dockerfiles or deployment configurations
- Inter-service communication patterns (APIs, message brokers)
- Service registry or discovery configuration
- API gateway configuration files
- Shared libraries or utilities across services" : ""}

<<<<<<< HEAD
${INCLUDES_FRONTEND == "Auto-detect" ?
=======
${INCLUDES_FRONTEND == "Auto-detect" ? 
>>>>>>> origin/main
"Identify frontend components by looking for:
- Web asset directories (wwwroot, public, dist, static)
- UI framework files (components, modules, pages)
- Frontend build configuration (webpack, vite, rollup, etc.)
- Style sheet organization (CSS, SCSS, styled-components)
- Static asset organization (images, fonts, icons)" : ""}

### 1. Structural Overview

Provide a high-level overview of the ${PROJECT_TYPE == "Auto-detect" ? "detected project type(s)" : PROJECT_TYPE} project's organization principles and folder structure:

- Document the overall architectural approach reflected in the folder structure
- Identify the main organizational principles (by feature, by layer, by domain, etc.)
- Note any structural patterns that repeat throughout the codebase
- Document the rationale behind the structure where it can be inferred

<<<<<<< HEAD
${IS_MONOREPO == "Auto-detect" ?
"If detected as a monorepo, explain how the monorepo is organized and the relationship between projects." :
IS_MONOREPO ? "Explain how the monorepo is organized and the relationship between projects." : ""}

${INCLUDES_MICROSERVICES == "Auto-detect" ?
"If microservices are detected, describe how they are structured and organized." :
=======
${IS_MONOREPO == "Auto-detect" ? 
"If detected as a monorepo, explain how the monorepo is organized and the relationship between projects." : 
IS_MONOREPO ? "Explain how the monorepo is organized and the relationship between projects." : ""}

${INCLUDES_MICROSERVICES == "Auto-detect" ? 
"If microservices are detected, describe how they are structured and organized." : 
>>>>>>> origin/main
INCLUDES_MICROSERVICES ? "Describe how the microservices are structured and organized." : ""}

### 2. Directory Visualization

<<<<<<< HEAD
${VISUALIZATION_STYLE == "ASCII" ?
"Create an ASCII tree representation of the folder hierarchy to depth level ${DEPTH_LEVEL}." : ""}

${VISUALIZATION_STYLE == "Markdown List" ?
"Use nested markdown lists to represent the folder hierarchy to depth level ${DEPTH_LEVEL}." : ""}

${VISUALIZATION_STYLE == "Table" ?
"Create a table with columns for Path, Purpose, Content Types, and Conventions." : ""}

${INCLUDE_GENERATED_FOLDERS ?
"Include all folders including generated ones." :
=======
${VISUALIZATION_STYLE == "ASCII" ? 
"Create an ASCII tree representation of the folder hierarchy to depth level ${DEPTH_LEVEL}." : ""}

${VISUALIZATION_STYLE == "Markdown List" ? 
"Use nested markdown lists to represent the folder hierarchy to depth level ${DEPTH_LEVEL}." : ""}

${VISUALIZATION_STYLE == "Table" ? 
"Create a table with columns for Path, Purpose, Content Types, and Conventions." : ""}

${INCLUDE_GENERATED_FOLDERS ? 
"Include all folders including generated ones." : 
>>>>>>> origin/main
"Exclude auto-generated folders like bin/, obj/, node_modules/, etc."}

### 3. Key Directory Analysis

Document each significant directory's purpose, contents, and patterns:

<<<<<<< HEAD
${PROJECT_TYPE == "Auto-detect" ?
"For each detected technology, analyze directory structures based on observed usage patterns:" : ""}

${(PROJECT_TYPE == ".NET" || PROJECT_TYPE == "Auto-detect") ?
"#### .NET Project Structure (if detected)

- **Solution Organization**:
=======
${PROJECT_TYPE == "Auto-detect" ? 
"For each detected technology, analyze directory structures based on observed usage patterns:" : ""}

${(PROJECT_TYPE == ".NET" || PROJECT_TYPE == "Auto-detect") ? 
"#### .NET Project Structure (if detected)

- **Solution Organization**: 
>>>>>>> origin/main
  - How projects are grouped and related
  - Solution folder organization patterns
  - Multi-targeting project patterns

- **Project Organization**:
  - Internal folder structure patterns
  - Source code organization approach
  - Resource organization
  - Project dependencies and references

- **Domain/Feature Organization**:
  - How business domains or features are separated
  - Domain boundary enforcement patterns

- **Layer Organization**:
  - Separation of concerns (Controllers, Services, Repositories, etc.)
  - Layer interaction and dependency patterns

- **Configuration Management**:
  - Configuration file locations and purposes
  - Environment-specific configurations
  - Secret management approach

- **Test Project Organization**:
  - Test project structure and naming
  - Test categories and organization
  - Test data and mock locations" : ""}

<<<<<<< HEAD
${(PROJECT_TYPE == "React" || PROJECT_TYPE == "Angular" || PROJECT_TYPE == "Auto-detect") ?
=======
${(PROJECT_TYPE == "React" || PROJECT_TYPE == "Angular" || PROJECT_TYPE == "Auto-detect") ? 
>>>>>>> origin/main
"#### UI Project Structure (if detected)

- **Component Organization**:
  - Component folder structure patterns
  - Grouping strategies (by feature, type, etc.)
  - Shared vs. feature-specific components

- **State Management**:
  - State-related file organization
  - Store structure for global state
  - Local state management patterns

- **Routing Organization**:
  - Route definition locations
  - Page/view component organization
  - Route parameter handling

- **API Integration**:
  - API client organization
  - Service layer structure
  - Data fetching patterns

- **Asset Management**:
  - Static resource organization
  - Image/media file structure
  - Font and icon organization
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Style Organization**:
  - CSS/SCSS file structure
  - Theme organization
  - Style module patterns" : ""}

### 4. File Placement Patterns

<<<<<<< HEAD
${INCLUDE_FILE_PATTERNS ?
=======
${INCLUDE_FILE_PATTERNS ? 
>>>>>>> origin/main
"Document the patterns that determine where different types of files should be placed:

- **Configuration Files**:
  - Locations for different types of configuration
  - Environment-specific configuration patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Model/Entity Definitions**:
  - Where domain models are defined
  - Data transfer object (DTO) locations
  - Schema definition locations
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Business Logic**:
  - Service implementation locations
  - Business rule organization
  - Utility and helper function placement
<<<<<<< HEAD

- **Interface Definitions**:
  - Where interfaces and abstractions are defined
  - How interfaces are grouped and organized

=======
  
- **Interface Definitions**:
  - Where interfaces and abstractions are defined
  - How interfaces are grouped and organized
  
>>>>>>> origin/main
- **Test Files**:
  - Unit test location patterns
  - Integration test placement
  - Test utility and mock locations
<<<<<<< HEAD

- **Documentation Files**:
  - API documentation placement
  - Internal documentation organization
  - README file distribution" :
=======
  
- **Documentation Files**:
  - API documentation placement
  - Internal documentation organization
  - README file distribution" : 
>>>>>>> origin/main
"Document where key file types are located in the project."}

### 5. Naming and Organization Conventions
Document the naming and organizational conventions observed across the project:

- **File Naming Patterns**:
  - Case conventions (PascalCase, camelCase, kebab-case)
  - Prefix and suffix patterns
  - Type indicators in filenames
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Folder Naming Patterns**:
  - Naming conventions for different folder types
  - Hierarchical naming patterns
  - Grouping and categorization conventions
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Namespace/Module Patterns**:
  - How namespaces/modules map to folder structure
  - Import/using statement organization
  - Internal vs. public API separation

- **Organizational Patterns**:
  - Code co-location strategies
  - Feature encapsulation approaches
  - Cross-cutting concern organization

### 6. Navigation and Development Workflow
Provide guidance for navigating and working with the codebase structure:

- **Entry Points**:
  - Main application entry points
  - Key configuration starting points
  - Initial files for understanding the project

- **Common Development Tasks**:
  - Where to add new features
  - How to extend existing functionality
  - Where to place new tests
  - Configuration modification locations
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Dependency Patterns**:
  - How dependencies flow between folders
  - Import/reference patterns
  - Dependency injection registration locations

<<<<<<< HEAD
${INCLUDE_FILE_COUNTS ?
=======
${INCLUDE_FILE_COUNTS ? 
>>>>>>> origin/main
"- **Content Statistics**:
  - Files per directory analysis
  - Code distribution metrics
  - Complexity concentration areas" : ""}

### 7. Build and Output Organization
Document the build process and output organization:

- **Build Configuration**:
  - Build script locations and purposes
  - Build pipeline organization
  - Build task definitions
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Output Structure**:
  - Compiled/built output locations
  - Output organization patterns
  - Distribution package structure
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Environment-Specific Builds**:
  - Development vs. production differences
  - Environment configuration strategies
  - Build variant organization

### 8. Technology-Specific Organization

<<<<<<< HEAD
${(PROJECT_TYPE == ".NET" || PROJECT_TYPE == "Auto-detect") ?
=======
${(PROJECT_TYPE == ".NET" || PROJECT_TYPE == "Auto-detect") ? 
>>>>>>> origin/main
"#### .NET-Specific Structure Patterns (if detected)

- **Project File Organization**:
  - Project file structure and patterns
  - Target framework configuration
  - Property group organization
  - Item group patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Assembly Organization**:
  - Assembly naming patterns
  - Multi-assembly architecture
  - Assembly reference patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Resource Organization**:
  - Embedded resource patterns
  - Localization file structure
  - Static web asset organization
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Package Management**:
  - NuGet configuration locations
  - Package reference organization
  - Package version management" : ""}

<<<<<<< HEAD
${(PROJECT_TYPE == "Java" || PROJECT_TYPE == "Auto-detect") ?
=======
${(PROJECT_TYPE == "Java" || PROJECT_TYPE == "Auto-detect") ? 
>>>>>>> origin/main
"#### Java-Specific Structure Patterns (if detected)

- **Package Hierarchy**:
  - Package naming and nesting conventions
  - Domain vs. technical packages
  - Visibility and access patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Build Tool Organization**:
  - Maven/Gradle structure patterns
  - Module organization
  - Plugin configuration patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Resource Organization**:
  - Resource folder structures
  - Environment-specific resources
  - Properties file organization" : ""}

<<<<<<< HEAD
${(PROJECT_TYPE == "Node.js" || PROJECT_TYPE == "Auto-detect") ?
=======
${(PROJECT_TYPE == "Node.js" || PROJECT_TYPE == "Auto-detect") ? 
>>>>>>> origin/main
"#### Node.js-Specific Structure Patterns (if detected)

- **Module Organization**:
  - CommonJS vs. ESM organization
  - Internal module patterns
  - Third-party dependency management
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Script Organization**:
  - npm/yarn script definition patterns
  - Utility script locations
  - Development tool scripts
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Configuration Management**:
  - Configuration file locations
  - Environment variable management
  - Secret management approaches" : ""}

### 9. Extension and Evolution
Document how the project structure is designed to be extended:

- **Extension Points**:
  - How to add new modules/features while maintaining conventions
  - Plugin/extension folder patterns
  - Customization directory structures
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Scalability Patterns**:
  - How the structure scales for larger features
  - Approach for breaking down large modules
  - Code splitting strategies
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Refactoring Patterns**:
  - Common refactoring approaches observed
  - How structural changes are managed
  - Incremental reorganization patterns

<<<<<<< HEAD
${INCLUDE_TEMPLATES ?
=======
${INCLUDE_TEMPLATES ? 
>>>>>>> origin/main
"### 10. Structure Templates

Provide templates for creating new components that follow project conventions:

- **New Feature Template**:
  - Folder structure for adding a complete feature
  - Required file types and their locations
  - Naming patterns to follow
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **New Component Template**:
  - Directory structure for a typical component
  - Essential files to include
  - Integration points with existing structure
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **New Service Template**:
  - Structure for adding a new service
  - Interface and implementation placement
  - Configuration and registration patterns
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **New Test Structure**:
  - Folder structure for test projects/files
  - Test file organization templates
  - Test resource organization" : ""}

### ${INCLUDE_TEMPLATES ? "11" : "10"}. Structure Enforcement

Document how the project structure is maintained and enforced:

- **Structure Validation**:
  - Tools/scripts that enforce structure
  - Build checks for structural compliance
  - Linting rules related to structure
<<<<<<< HEAD

=======
  
>>>>>>> origin/main
- **Documentation Practices**:
  - How structural changes are documented
  - Where architectural decisions are recorded
  - Structure evolution history

Include a section at the end about maintaining this blueprint and when it was last updated.
"
