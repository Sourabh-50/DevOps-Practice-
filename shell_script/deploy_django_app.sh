#!/bin/bash
# Deploy a Django app and handle errors

code_clone() {
    echo "Cloning the Django app..."
    if [ -d "django-notes-app" ]; then
        echo "The code directory already exists. Skipping clone."
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git || {
            echo "Failed to clone the code."
            return 1
        }
    fi
}

install_requirements() {
    echo "Installing dependencies..."

    sudo dnf install -y docker nginx git || {
        echo "Failed to install dependencies."
        return 1
    }
}

required_restarts() {
    echo "Performing required restarts..."
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
}

deploy() {
    echo "Building and deploying the Django app..."

    cd django-notes-app || return 1

    docker-compose up -d --build || {
        echo "Failed to build and deploy the app."
    }
}

echo "********** DEPLOYMENT STARTED *********"

if ! code_clone; then
    exit 1
fi

if ! install_requirements; then
    exit 1
fi

if ! required_restarts; then
    exit 1
fi

if ! deploy; then
    echo "Deployment failed. Mailing the admin..."
    exit 1
fi

echo "********** DEPLOYMENT DONE *********"
