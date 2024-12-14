param (
    [string]$param,
    [string]$version,
    [string]$name
)

# Check if the $dev variable is defined
if (-not $dev) {
    Write-Host "`nThe variable `$DEV is not defined. Please check your `$PROFILE file."
    Write-Host "Add `$DEV = 'your\dev\directory' to set up the development environment." 
    Write-Host "`n"
    return
}

# Display usage if no parameter is provided
if (-not $param) {
    Write-Host "`nUsage: venvs <parameter>"
    Write-Host "`nAvailable parameters:"
    Write-Host "  local    - Returns the path D:\dev\python\.venvs"
    Write-Host "  install  - Installs a virtual environment with the specified version and name"
    Write-Host "  activate - Activates a virtual environment with the specified name"
    Write-Host "`n"
    return
}

# Handle the "local" parameter
if ($param -eq "local") {
    $localPath = Join-Path -Path $dev -ChildPath "python\.venvs"
    Write-Output $localPath
}

# Handle the "install" parameter
elseif ($param -eq "install") {
    if (-not $version -or -not $name) {
        Write-Host "`nUsage: venvs install -version <version> -name <name>`n"
        return
    }

    # Define the path to the venv directory
    $venvPath = Join-Path -Path $dev -ChildPath "python\.venvs\$name"
    
    # Check if the venv already exists
    if (Test-Path $venvPath) {
        Write-Host "The virtual environment '$name' already exists at $venvPath"
        return
    }

    # Check if the specified version of Python is installed with pyenv
    $pyenvVersions = pyenv versions | Out-String
    $isVersionFound = $pyenvVersions.Contains($version)

    # Print the version check result for debugging
    Write-Host "`nAvailable pyenv versions:"
    Write-Host $pyenvVersions
    Write-Host "Is version $version installed? $isVersionFound"

    if (-not $isVersionFound) {
        Write-Host "Python version $version is not installed with pyenv. Installing now..."
        
        # Install the specified version using pyenv
        $installCommand = "pyenv install $version"
        Write-Host "Running: $installCommand"
        Invoke-Expression $installCommand

        # Re-check if the version is installed
        $pyenvVersions = pyenv versions | Out-String
        $isVersionFound = $pyenvVersions.Contains($version)

        if (-not $isVersionFound) {
            Write-Host "Failed to install Python $version with pyenv. Please check the installation. `n"
            return
        }

        Write-Host "Python $version installed successfully with pyenv."
    }

    # Set the local version to the requested version
    $setVersionCommand = "pyenv local $version"
    Write-Host "Setting Python version to $version using pyenv..."
    Invoke-Expression $setVersionCommand

    # Create the virtual environment using the selected Python version
    Write-Host "Creating virtual environment '$name' at $venvPath using Python $version..."
    pyenv exec python -m venv $venvPath

    Write-Host "Virtual environment '$name' created successfully at $venvPath `n"
}

# Handle the "activate" parameter
elseif ($param -eq "activate") {
    if (-not $name) {
        Write-Host "`nUsage: venvs activate -name <name>`n"
        return
    }

    # Define the path to the venv directory
    $venvPath = Join-Path -Path $dev -ChildPath "python\.venvs\$name"

    # Check if the venv exists
    if (-not (Test-Path $venvPath)) {
        Write-Host "`nThe virtual environment '$name' does not exist at $venvPath`n"
        return
    }

    # Define the correct activation script for Windows (Scripts\Activate.ps1)
    $activateScript = Join-Path -Path $venvPath -ChildPath "Scripts\Activate.ps1"

    # Check if the script exists
    if (Test-Path $activateScript) {
        Write-Host "`nActivating virtual environment '$name'...`n"
        
        # Dot source the activation script to activate the venv in the current session
        . $activateScript
    }
    else {
        Write-Host "`nUnable to find activation script at $activateScript. Please check your virtual environment.`n"
    }
}

# Invalid parameter
else {
    Write-Host "Invalid command. Please use one of the available parameters."
}
