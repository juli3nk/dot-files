# Git

## Config

`.config/git/config`

```ini
[user]
    name = <NAME>
    email = <EMAIL>

[includeIf "gitdir:~/new/path/"]
    path = ~/.config/git/config-new
```

`.config/git/config-new`

```ini
[user]
    email = <EMAIL>
```

## GitFlow

https://www.atlassian.com/fr/git/tutorials/comparing-workflows/gitflow-workflow

## Rename master branch to main
### Renaming the Local master Branch to main

The first step is to rename the "master" branch in your local Git repositories:

```shell
$ git branch -m master main
```

Let's quickly check if this has worked as expected:

```shell
$ git status
On branch main
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

### Renaming the Remote master Branch as Well

In the second step, we'll have to create a new branch on the remote named "main" - because Git does not allow to simply "rename" a remote branch. Instead, we'll have to create a new "main" branch and then delete the old "master" branch.

Make sure your current local HEAD branch is still "main" when executing the following command:

```shell
$ git push -u origin main
```

We now have a new branch on the remote named "main". Let's go on and remove the old "master" branch on the remote:

```shell
$ git push origin --delete master
```

### What Your Teammates Have to Do

If other people on your team have local clones of the repository, they will also have to perform some steps on their end:

```shell
# Switch to the "master" branch:
$ git checkout master

# Rename it to "main":
$ git branch -m master main

# Get the latest commits (and branches!) from the remote:
$ git fetch

# Remove the existing tracking connection with "origin/master":
$ git branch --unset-upstream

# Create a new tracking connection with the new "origin/main" branch:
$ git branch -u origin/main
```
