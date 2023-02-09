
# rewrite git log author info
git_log_rewrite_author() {
	if [ -z "$1" -a -z "$2" -a -z "$3" ]; then
		echo "usage: git_log_rewrite_author <name|email> <old_value> <new_value>"
		return;
	fi

	if [ "$1" != "name" -o "$1" != "email" ]; then
		echo "error: first parameter must be \'name\' or \'email\'"
		return;
	fi

	git filter-branch --commit-filter '
		if [ "$1" == "name" -a "$GIT_AUTHOR_NAME" == $2 ]; then
			GIT_AUTHOR_NAME="$3";
		elif [ "$1" == "email" -a "$GIT_AUTHOR_EMAIL" == $2 ]; then
			GIT_AUTHOR_EMAIL=$3;

			git commit-tree "$@";
		else
			git commit-tree "$@";
		fi' HEAD
}
