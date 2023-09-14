# Git

## Config

.config/git/config

```
[user]
    name = <NAME>
    email = <EMAIL>

[includeIf "gitdir:~/new/path/"]
    path = ~/.config/git/config-new
```

.config/git/config-new

```
[user]
    email = <EMAIL>
```

## GitFlow

https://www.atlassian.com/fr/git/tutorials/comparing-workflows/gitflow-workflow
