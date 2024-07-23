# ------------------------------------------
# For commiting to github for the first time
rm -rf .git
git init
# ------------------------------------------
# upload to github
chmod -R 777 *
git add .
git commit -m 'updated OpenHPC-Slurm-Setup-for-Single-Node Instructions'
# ------------------------------------------
# For commiting to github for the first time
git branch -M main
git remote add origin git@github.com:geoffreyweal/OpenHPC-Slurm-Setup-for-Single-Node.git
git push -uf origin main
# ------------------------------------------
# push your new commit:
#git push -u origin main
# ------------------------------------------
# Remove the .git file. I dont want to keep it
rm -rf .git
# ------------------------------------------