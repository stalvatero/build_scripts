#!/bin/bash

set -e

## handle command line arguments
read -p "Do you want to delete .repo unused folders? (y/N) " choice

# Initialize local repository
function delete_unused_repo() {   
	rm -rf .repo/manifests && echo ".repo/manifests/ --- deleted"
	rm -rf .repo/manifests.git && echo ".repo/manifests.git --- deleted"
	rm -rf .repo/repo && echo ".repo/repo/ --- deleted"
	rm -rf .repo/manifest.xml && echo ".repo/manifest.xml --- deleted"
	rm -rf .repo/project.list && echo ".repo/project.list --- deleted"
	rm -rf .repo/.repo_fetchtimes.json && echo ".repo/.repo_fetchtimes.json --- deleted"
	echo "repo was cleaned"
}

if [[ $choice == *"y"* ]]; then
	delete_unused_repo
fi

echo "Done"

