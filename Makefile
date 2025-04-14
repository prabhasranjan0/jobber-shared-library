# === Configuration ===
GITHUB_USERNAME = prabhasranjan0
LIBRARY_NAME = jobber-shared-library
AUTHOR = prabhasranjan0
REPO_URL = git+https://github.com/$(GITHUB_USERNAME)/$(LIBRARY_NAME).git

# Load environment variables from .env
ifneq ($(wildcard .env),)
  export $(shell sed 's/=.*//' .env)
endif

# === Commands ===

init:
	@echo "🔄 Reinitializing Git repository..."
	rm -rf .git
	git init
	@echo "✅ Git repo reinitialized."

configure-npmrc:
	@echo "⚙️  Configuring .npmrc with GitHub registry..."
	echo "@$(GITHUB_USERNAME):registry=https://npm.pkg.github.com/$(GITHUB_USERNAME)" > .npmrc
	echo "//npm.pkg.github.com/:_authToken=${NPM_TOKEN}" >> .npmrc
	@echo "✅ .npmrc configured."

update-package-json:
	@echo "📝 Updating package.json..."
	npx json -I -f package.json -e 'this.name="@$(GITHUB_USERNAME)/$(LIBRARY_NAME)"'
	npx json -I -f package.json -e 'this.author="$(AUTHOR)"'
	npx json -I -f package.json -e 'this.repository={"type":"git","url":"$(REPO_URL)"}'
	@echo "✅ package.json updated."

prepare:
	@echo "📦 Preparing shared library for GitHub Package Registry..."
	make init
	make configure-npmrc
	make update-package-json

publish:
	@echo "🚀 Publishing package to GitHub..."
	npm publish
	@echo "✅ Package published!"

# Push code to GitHub
push:
	@echo "📡 Pushing code to GitHub..."
	git add .
	git commit -m "📦 Publish shared library"
	git remote add origin https://github.com/$(GITHUB_USERNAME)/$(LIBRARY_NAME).git || true
	git branch -M main
	git push -u origin main
	@echo "✅ Code pushed."

# All steps
all: prepare push

.PHONY: init configure-npmrc update-package-json prepare publish push all
