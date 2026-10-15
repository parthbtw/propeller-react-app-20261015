#!/usr/bin/env bash
set -euo pipefail

# One-time command record for the completed GitHub exercise.
# Prerequisites: Node.js, npm, Python 3, Git with author name/email configured,
# curl, and authenticated GitHub CLI on PATH.
# GitHub CLI 2.102.0 was installed temporarily in the workspace.
# Login used: gh auth login --hostname github.com --git-protocol https --web --skip-ssh-key
# REPO_URL https://github.com/parthbtw/propeller-react-app-20261015

# 1. Create the React app using Create React App.
npm_config_cache="$PWD/npm-cache" npx --yes create-react-app@5.1.0 propeller-react-app --use-npm
cd propeller-react-app

# 2. Commit the starter app and create/push a public GitHub repository.
# CRA creates an initial commit; amend its message before the first push.
git branch -M master
git add .
git commit --amend -m "Initialize Create React App"
# Use the authenticated CLI for Git in this repository only.
git config --local credential.helper ''
git config --local --add credential.helper '!gh auth git-credential'
gh repo create parthbtw/propeller-react-app-20261015 --public --source=. --remote=origin --push --description "Create React App exercise with a Propeller logo and Dirtmate link"
gh repo edit parthbtw/propeller-react-app-20261015 --default-branch master

# 3. Switch to update_logo.
git switch -c update_logo

# 4. Replace the existing logo with the exact supplied SVG.
curl --fail --location --silent --show-error 'https://cdn-ikponof.nitrocdn.com/vGqfYAGlOLDkYkJqZhYIYKEsibdbZnkc/assets/images/optimized/rev-f684a87/www.propelleraero.com/wp-content/uploads/2023/05/footer-logo.svg' --output src/logo.svg

# 5. Replace the link and fit the supplied wide, dark logo to the page.
# Update the existing starter test to match the new link label.
# The update script is included here so the record can be reproduced.
cat > ../update_app.py <<'PY_UPDATE'
from pathlib import Path

app_path = Path('src/App.js')
app = app_path.read_text()
assert 'href="https://reactjs.org"' in app
app = app.replace('href="https://reactjs.org"', 'href="https://www.propelleraero.com/dirtmate/"')
app = app.replace('alt="logo"', 'alt="Propeller"')
app = app.replace('Learn React', 'Explore Dirtmate')
app_path.write_text(app)

css_path = Path('src/App.css')
css = css_path.read_text()
assert 'height: 40vmin;' in css
css = css.replace('height: 40vmin;', 'width: min(70vw, 480px);\n  height: auto;')
css = css.replace('@media (prefers-reduced-motion: no-preference) {\n  .App-logo {\n    animation: App-logo-spin infinite 20s linear;\n  }\n}\n\n', '')
css = css.replace('background-color: #282c34;', 'background-color: #f5f7fa;')
css = css.replace('color: white;', 'color: #08111d;')
css = css.replace('color: #61dafb;', 'color: #0073b5;')
css = css[:css.index('\n@keyframes App-logo-spin')].rstrip() + '\n'
css_path.write_text(css)

test_path = Path('src/App.test.js')
test = test_path.read_text()
test = test.replace('renders learn react link', 'renders Dirtmate link')
test = test.replace('/learn react/i', '/explore dirtmate/i')
test_path.write_text(test)
PY_UPDATE
python3 ../update_app.py

# 6. Verify the app, commit the changes, and push update_logo.
CI=true npm test -- --watchAll=false --runInBand
npm run build
# command.sh is this command record, saved in the app before the commit.
git add src/logo.svg src/App.js src/App.css src/App.test.js command.sh
git commit -m "Replace React logo and link with Propeller Dirtmate"
git push -u origin update_logo

# 7. Create a PR from update_logo to master using GitHub CLI.
cat > ../pr-body.md <<'PR_BODY'
Replace the starter React logo with the supplied Propeller SVG and direct the page link to https://www.propelleraero.com/dirtmate/.

The logo scales to fit smaller screens, stays stationary, and uses a light background for contrast. The existing starter test uses the updated link label. command.sh records the exercise commands and public repository URL.

Validation: the existing test passes and the production build succeeds.
PR_BODY
gh pr create --base master --head update_logo --title "Replace starter logo and link with Propeller Dirtmate" --body-file ../pr-body.md

# 8. Merge the PR using GitHub CLI; reviewer approval skipped as requested.
gh pr merge update_logo --merge --match-head-commit "$(git rev-parse HEAD)"
git switch master
git pull --ff-only origin master

# Verify the public repository and merged PR.
gh repo view --json url,visibility,defaultBranchRef
gh pr view 1 --json url,state,baseRefName,headRefName,mergedAt,mergeCommit
