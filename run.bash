#!/usr/bin/env bash
echo "Hello world!" # => Hello world!
if ! love --version &> /dev/null
then
    echo "Love2D is not installed. Please install Love2D to run this application."
    echo "Visit https://love2d.org/ for installation instructions."
    sudo snap install love
else
    echo "Starting Love2D application..."
    love --version
    love .
fi